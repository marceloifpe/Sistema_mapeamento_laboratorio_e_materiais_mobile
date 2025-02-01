import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sistema_mapeamento_de_materiais/services/database.dart';
import 'package:sistema_mapeamento_de_materiais/pages/login.dart';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GerenciarSalasPage extends StatefulWidget {
  @override
  _GerenciarSalasPageState createState() => _GerenciarSalasPageState();
}

class _GerenciarSalasPageState extends State<GerenciarSalasPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _adicionarOuEditarSala({String? id, String? nome, String? local}) {
    String novoNome = nome ?? "";
    String novoLocal = local ?? "UABJ"; // Valor padrão

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(id == null ? "Adicionar Sala" : "Editar Sala"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: "Nome da Sala"),
                onChanged: (value) => novoNome = value,
                controller: TextEditingController(text: nome),
              ),
              DropdownButtonFormField<String>(
                value: novoLocal,
                decoration: InputDecoration(labelText: "Local da Sala"),
                items: ["UABJ", "AEB"].map((String local) {
                  return DropdownMenuItem(value: local, child: Text(local));
                }).toList(),
                onChanged: (value) => novoLocal = value!,
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
                    await _firestore.collection("salas").add({
                      "nome_da_sala": novoNome,
                      "local": novoLocal,
                      "reservado": false, // Sempre começa como falso
                    });
                  } else {
                    // Atualiza uma sala existente
                    await _firestore.collection("salas").doc(id).update({
                      "nome_da_sala": novoNome,
                      "local": novoLocal,
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
    _firestore.collection("salas").doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Gerenciar Salas"),
        backgroundColor: Color(0xff1F509A),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection("salas").snapshots(),
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
                title: Text(salaData["nome_da_sala"]),
                subtitle: Text("Local: ${salaData["local"]}"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _adicionarOuEditarSala(
                        id: sala.id,
                        nome: salaData["nome_da_sala"],
                        local: salaData["local"],
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
