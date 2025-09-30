import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/utils/api_config.dart';

class RegisterPetPage extends StatefulWidget {
  const RegisterPetPage({Key? key}) : super(key: key);

  @override
  State<RegisterPetPage> createState() => _RegisterPetPageState();
}

class _RegisterPetPageState extends State<RegisterPetPage> {
  final _formKey = GlobalKey<FormState>();
  String nome = '';
  String idade = '';
  String porte = '';
  String raca = '';
  File? _imageFile;
  String? _imageBase64;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _imageBase64 = base64Encode(bytes);
      });
    }
  }

  Future<int?> getUsuarioId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id'); // Corrigido para user_id
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final usuarioId = await getUsuarioId();

      if (usuarioId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: usuário não identificado')),
        );
        return;
      }

      try {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('jwt_token'); // Corrigido para jwt_token
        final uri = Uri.parse('${ApiConfig.baseUrl}/pets');
        var request = http.MultipartRequest('POST', uri);

        if (token != null) {
          request.headers['Authorization'] = 'Bearer $token';
        }

        request.fields['nome'] = nome;
        request.fields['idade'] = idade;
        request.fields['porte'] = porte;
        request.fields['raca'] = raca;
        request.fields['usuarioId'] = usuarioId.toString();

        // Foto é opcional
        if (_imageFile != null) {
          request.files.add(
            await http.MultipartFile.fromPath('foto', _imageFile!.path),
          );
        }

        print('📱 Enviando dados do pet: nome=$nome, usuarioId=$usuarioId');
        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);

        print('📱 Status cadastro pet: ${response.statusCode}');
        print('📱 Response body: ${response.body}');

        if (response.statusCode == 201) {
          try {
            final data = jsonDecode(response.body);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(data['message'] ?? 'Pet cadastrado com sucesso!'),
              ),
            );
          } catch (_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Pet cadastrado com sucesso!')),
            );
          }
          Navigator.pop(context, true);
        } else {
          String errorMsg = 'Erro ao cadastrar pet';
          try {
            final data = jsonDecode(response.body);
            errorMsg = data['message'] ?? errorMsg;
          } catch (_) {
            errorMsg = response.body;
          }
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(errorMsg)));
        }
      } catch (e) {
        print('❌ Erro ao cadastrar pet: $e');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro de conexão: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 4,
        shadowColor: Colors.blue.shade200,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Cadastre seu Pet',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: false,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Nome do pet',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onSaved: (value) => nome = value ?? '',
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Informe o nome' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Idade',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  onSaved: (value) => idade = value ?? '',
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Informe a idade' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Porte',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.blue, width: 2),
                    ),
                  ),
                  dropdownColor: Colors.white,
                  style: TextStyle(color: Colors.black),
                  items: const [
                    DropdownMenuItem(value: 'Pequeno', child: Text('Pequeno')),
                    DropdownMenuItem(value: 'Médio', child: Text('Médio')),
                    DropdownMenuItem(value: 'Grande', child: Text('Grande')),
                  ],
                  onChanged: (value) => setState(() => porte = value ?? ''),
                  onSaved: (value) => porte = value ?? '',
                  validator: (value) => value == null || value.isEmpty
                      ? 'Selecione o porte'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Raça',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onSaved: (value) => raca = value ?? '',
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Informe a raça' : null,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Adicione uma foto do seu pet:',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 12),
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F5FF),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: _imageFile != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: Image.file(_imageFile!, fit: BoxFit.cover),
                            )
                          : const Icon(
                              Icons.camera_alt_outlined,
                              size: 48,
                              color: Colors.black,
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: _submitForm,
                        child: const Text(
                          'Cadastrar',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
