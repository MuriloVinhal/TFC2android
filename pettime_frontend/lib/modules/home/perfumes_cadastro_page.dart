import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/utils/api_config.dart';

class PerfumesCadastroPage extends StatefulWidget {
  const PerfumesCadastroPage({Key? key}) : super(key: key);

  @override
  State<PerfumesCadastroPage> createState() => _PerfumesCadastroPageState();
}

class _PerfumesCadastroPageState extends State<PerfumesCadastroPage> {
  final _formKey = GlobalKey<FormState>();
  String descricao = '';
  String observacao = '';
  File? _imageFile;
  String? imagemUrl;
  int? idPerfume;
  final ImagePicker _picker = ImagePicker();
  bool carregando = false;
  bool isEdit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is Map<String, dynamic> && !isEdit) {
      idPerfume = args['id'];
      descricao = args['descricao'] ?? '';
      observacao = args['observacao'] ?? '';
      imagemUrl = args['imagem'];
      isEdit = true;
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        imagemUrl = null;
      });
    }
  }

  Future<void> _salvarPerfume() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() => carregando = true);
    try {
      var uri = isEdit
          ? Uri.parse('${ApiConfig.baseUrl}/produtos/$idPerfume')
          : Uri.parse('${ApiConfig.baseUrl}/produtos');
      var request = isEdit
          ? http.MultipartRequest('PUT', uri)
          : http.MultipartRequest('POST', uri);
      request.fields['descricao'] = descricao;
      request.fields['observacao'] = observacao;
      request.fields['tipo'] = '2'; // perfume
      if (_imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath('imagem', _imageFile!.path),
        );
      }
      var response = await request.send();
      if (response.statusCode == 201 || response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEdit
                  ? 'Perfume atualizado!'
                  : 'Perfume cadastrado com sucesso!',
            ),
          ),
        );
        Navigator.pop(context, true);
      } else {
        String msg = isEdit
            ? 'Erro ao atualizar perfume'
            : 'Erro ao cadastrar perfume';
        try {
          final respStr = await response.stream.bytesToString();
          final data = jsonDecode(respStr);
          msg = data['message'] ?? msg;
        } catch (_) {}
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(msg)));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro de conexão: $e')));
    } finally {
      setState(() => carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          isEdit ? 'Editar perfume' : 'Cadastro de perfumes',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 8),
              const Text(
                'Descrição:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              TextFormField(
                initialValue: descricao,
                decoration: const InputDecoration(
                  hintText: 'Informe uma descrição/nome do produto.',
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Informe a descrição' : null,
                onSaved: (v) => descricao = v ?? '',
              ),
              const SizedBox(height: 16),
              const Text(
                'Observações:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              TextFormField(
                initialValue: observacao,
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText: 'Informe os dados do produto cadastrado:',
                ),
                onSaved: (v) => observacao = v ?? '',
              ),
              const SizedBox(height: 24),
              const Text(
                'Adicione uma foto do perfume:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF0FF),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: _imageFile != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: Image.file(_imageFile!, fit: BoxFit.cover),
                          )
                        : (imagemUrl != null && imagemUrl!.isNotEmpty)
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: Image.network(
                              '${ApiConfig.baseUrl}$imagemUrl',
                              fit: BoxFit.cover,
                            ),
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
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: carregando ? null : _salvarPerfume,
                      child: carregando
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              isEdit ? 'Salvar' : 'Cadastrar',
                              style: const TextStyle(fontSize: 16),
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
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: carregando
                          ? null
                          : () {
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
    );
  }
}
