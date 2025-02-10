import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sistema_mapeamento_de_materiais/services/database.dart';
import 'package:sistema_mapeamento_de_materiais/pages/login.dart';
import 'package:sistema_mapeamento_de_materiais/Admin/TelaQrCode.dart';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GerenciarMateriaisPage extends StatefulWidget {
  @override
  _GerenciarMateriaisPageState createState() => _GerenciarMateriaisPageState();
}

class _GerenciarMateriaisPageState extends State<GerenciarMateriaisPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _adicionarOuEditarMaterial({
    String? id,
    String? nome,
  }) {
    String novoNome = nome ?? "";
    TextEditingController controller = TextEditingController(text: nome);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(id == null ? "Adicionar Material" : "Editar Material"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: "Nome do Material"),
                controller: controller,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancelar"),
            ),
            TextButton(
              onPressed: () async {
                novoNome = controller.text;
                if (novoNome.isNotEmpty) {
                  if (id == null) {
                    DocumentReference docRef =
                        await _firestore.collection("materiais").add({
                      "nome_do_material": novoNome,
                      "reservado": false,
                      "qr_code": "",
                    });
                    await docRef.update({
                      "qr_code": docRef.id,
                    });
                  } else {
                    await _firestore.collection("materiais").doc(id).update({
                      "nome_do_material": novoNome,
                    });
                  }
                }
                Navigator.pop(context);
              },
              child: Text(id == null ? "Adicionar" : "Salvar"),
            ),
          ],
        );
      },
    );
  }

  void _removerMaterial(String id) {
    _firestore.collection("materiais").doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Gerenciar Materiais"),
        backgroundColor: Color(0xff1F509A),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection("materiais").snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var materiais = snapshot.data!.docs;

          return ListView.builder(
            itemCount: materiais.length,
            itemBuilder: (context, index) {
              var material = materiais[index];
              var materialData = material.data() as Map<String, dynamic>;
              String qrCodeData = materialData["qr_code"] ?? "";

              return ListTile(
                title: Text(materialData["nome_do_material"]),
                subtitle: qrCodeData.isNotEmpty
                    ? GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  TelaQrCode(qrData: qrCodeData),
                            ),
                          );
                        },
                        child: SizedBox(
                          height: 60,
                          width: 60,
                          child: QrImageView(
                            data: qrCodeData,
                            version: QrVersions.auto,
                            size: 60.0,
                          ),
                        ),
                      )
                    : null,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _adicionarOuEditarMaterial(
                        id: material.id,
                        nome: materialData["nome_do_material"],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removerMaterial(material.id),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xff1F509A),
        child: Icon(Icons.add),
        onPressed: () => _adicionarOuEditarMaterial(),
      ),
    );
  }
}
