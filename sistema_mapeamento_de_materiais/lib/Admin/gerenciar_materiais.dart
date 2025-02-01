import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sistema_mapeamento_de_materiais/services/database.dart';
import 'package:sistema_mapeamento_de_materiais/pages/login.dart';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GerenciarMateriaisPage extends StatefulWidget {
  @override
  _GerenciarMateriaisPageState createState() => _GerenciarMateriaisPageState();
}

class _GerenciarMateriaisPageState extends State<GerenciarMateriaisPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _adicionarOuEditarSala({
    String? id,
    String? nome,
  }) {
    String novoNome = nome ?? "";

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
                onChanged: (value) => novoNome = value,
                controller: TextEditingController(text: nome),
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
                if (novoNome.isNotEmpty) {
                  if (id == null) {
                    // Adiciona uma nova sala
                    await _firestore.collection("materiais").add({
                      "nome_do_material": novoNome,

                      "reservado": false, // Sempre começa como falso
                    });
                  } else {
                    // Atualiza uma sala existente
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

  void _removerSala(String id) {
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

          var salas = snapshot.data!.docs;

          return ListView.builder(
            itemCount: salas.length,
            itemBuilder: (context, index) {
              var sala = salas[index];
              var salaData = sala.data() as Map<String, dynamic>;

              return ListTile(
                title: Text(salaData["nome_do_material"]),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _adicionarOuEditarSala(
                        id: sala.id,
                        nome: salaData["nome_do_material"],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removerSala(sala.id),
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
        onPressed: () => _adicionarOuEditarSala(),
      ),
    );
  }
}
