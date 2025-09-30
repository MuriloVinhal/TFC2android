import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/utils/api_config.dart';

class EditPetPage extends StatefulWidget {
  final Map<String, dynamic> pet;
  const EditPetPage({Key? key, required this.pet}) : super(key: key);

  @override
  State<EditPetPage> createState() => _EditPetPageState();
}

class _EditPetPageState extends State<EditPetPage> {
  final _formKey = GlobalKey<FormState>();
  late String nome;
  late String idade;
  late String porte;
  late String raca;
  File? _imageFile;
  String? _imageBase64;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    nome = widget.pet['nome'] ?? '';
    idade = widget.pet['idade']?.toString() ?? '';
    porte = widget.pet['porte'] ?? '';
    raca = widget.pet['raca'] ?? '';
    _imageBase64 = widget.pet['foto'];
  }

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

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<void> _salvarEdicao() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');
        final uri = Uri.parse('${ApiConfig.baseUrl}/pets/${widget.pet['id']}');
        var request = http.MultipartRequest('PUT', uri);
        if (token != null) {
          request.headers['Authorization'] = 'Bearer $token';
        }
        request.fields['nome'] = nome;
        request.fields['idade'] = idade;
        request.fields['porte'] = porte;
        request.fields['raca'] = raca;
        // Se não selecionar nova imagem, envie o caminho atual
        if (_imageFile != null) {
          request.files.add(
            await http.MultipartFile.fromPath('foto', _imageFile!.path),
          );
        } else if (_imageBase64 != null && _imageBase64!.isNotEmpty) {
          request.fields['foto'] = _imageBase64!;
        }
        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);
        if (response.statusCode == 200) {
          try {
            final data = jsonDecode(response.body);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(data['message'] ?? 'Pet atualizado com sucesso!'),
              ),
            );
          } catch (_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Pet atualizado com sucesso!')),
            );
          }
          Navigator.pop(context, true);
        } else {
          String errorMsg = 'Erro ao atualizar pet';
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro de conexão: $e')));
      }
    }
  }

  Future<void> _excluirPet() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Pet'),
        content: const Text('Tem certeza que deseja excluir este pet?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      try {
        final headers = await _getHeaders();
        final response = await http.delete(
          Uri.parse('${ApiConfig.baseUrl}/pets/${widget.pet['id']}'),
          headers: headers,
        );
        if (response.statusCode == 200 || response.statusCode == 204) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pet excluído com sucesso!')),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao excluir pet: \\n${response.body}')),
          );
        }
      } catch (e) {
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
        foregroundColor: Colors.white,
        title: const Text(
          'Editar Pet',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: _excluirPet,
            tooltip: 'Excluir',
          ),
        ],
      ),
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
                  initialValue: nome,
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
                  initialValue: idade,
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
                  value: porte.isNotEmpty ? porte : null,
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
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Selecione o porte' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: raca,
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
                  'Foto do pet:',
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
                          : (_imageBase64 != null && _imageBase64!.isNotEmpty)
                          ? Builder(
                              builder: (context) {
                                final url = '${ApiConfig.baseUrl}${_imageBase64!}';
                                print('URL da imagem: ' + url);
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(18),
                                  child: Image.network(
                                    url,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(
                                              Icons.broken_image,
                                              size: 48,
                                              color: Colors.red,
                                            ),
                                  ),
                                );
                              },
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
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _salvarEdicao,
                  child: const Text(
                    'Salvar Alterações',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
