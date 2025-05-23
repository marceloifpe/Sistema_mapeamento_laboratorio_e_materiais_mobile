import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_core/firebase_core.dart'; // Geralmente inicializado em main.dart
// import 'package:sistema_mapeamento_de_materiais/services/database.dart'; // Não usado diretamente
// import 'package:sistema_mapeamento_de_materiais/pages/login.dart'; // Não usado aqui

class GerenciarSalasPage extends StatefulWidget {
  const GerenciarSalasPage({super.key});

  @override
  _GerenciarSalasPageState createState() => _GerenciarSalasPageState();
}

class _GerenciarSalasPageState extends State<GerenciarSalasPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const Color kPrimaryColor = Color(0xFF091057);
  static const Color kAccentColor = Color(0xff1F509A);
  static const Color kLightTextColor = Colors.white;
  static const Color kDarkTextColor = Colors.black87;
  static const Color kScaffoldBackgroundColor = Color(0xFFF4F6F8);
  static const Color kCardBackgroundColor = Colors.white;
  static const Color kErrorColor = Colors.redAccent;
  static const Color kSuccessColor = Colors.green;

  final List<String> _locaisDisponiveis = ["UABJ", "AEB"];

  void _adicionarOuEditarSala({String? id, String? nome, String? local}) {
    String novoNome = nome ?? "";
    String novoLocal = (local != null && _locaisDisponiveis.contains(local))
        ? local
        : _locaisDisponiveis.first;

    TextEditingController nomeController = TextEditingController(text: nome);
    String? localSelecionadoNoDialog = novoLocal;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          title: Text(
            id == null ? "Adicionar Nova Sala" : "Editar Sala",
            style: const TextStyle(
                color: kPrimaryColor, fontWeight: FontWeight.bold),
          ),
          content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setStateDialog) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nomeController,
                  decoration: InputDecoration(
                    labelText: "Nome da Sala",
                    labelStyle: const TextStyle(color: kAccentColor),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: kPrimaryColor, width: 2.0),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    prefixIcon: const Icon(Icons.meeting_room_outlined,
                        color: kAccentColor),
                  ),
                  // onChanged: (value) => novoNome = value, // Atualizado para usar controller.text abaixo
                  style: const TextStyle(color: kDarkTextColor),
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: localSelecionadoNoDialog,
                  decoration: InputDecoration(
                    labelText: "Local da Sala",
                    labelStyle: const TextStyle(color: kAccentColor),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: kPrimaryColor, width: 2.0),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    prefixIcon: const Icon(Icons.location_on_outlined,
                        color: kAccentColor),
                  ),
                  items: _locaisDisponiveis.map((String localItem) {
                    return DropdownMenuItem(
                        value: localItem, child: Text(localItem));
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setStateDialog(() {
                        localSelecionadoNoDialog = value;
                      });
                      novoLocal =
                          value; // Atualiza a variável externa corretamente
                    }
                  },
                  style: const TextStyle(color: kDarkTextColor, fontSize: 16),
                  dropdownColor: kCardBackgroundColor,
                ),
              ],
            );
          }),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child:
                  const Text("Cancelar", style: TextStyle(color: kAccentColor)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)),
              ),
              onPressed: () async {
                novoNome = nomeController.text
                    .trim(); // Pega o valor final do controller
                // novoLocal já está atualizado pelo onChanged do Dropdown
                if (novoNome.isNotEmpty) {
                  if (id == null) {
                    await _firestore.collection("salas").add({
                      "nome_da_sala": novoNome,
                      "local": novoLocal,
                      "reservado": false,
                    });
                  } else {
                    await _firestore.collection("salas").doc(id).update({
                      "nome_da_sala": novoNome,
                      "local": novoLocal,
                    });
                  }
                }
                if (mounted) Navigator.pop(context);
              },
              child: Text(id == null ? "Adicionar" : "Salvar Alterações",
                  style: const TextStyle(color: kLightTextColor)),
            ),
          ],
        );
      },
    );
  }

  void _removerSala(String id) {
    _firestore.collection("salas").doc(id).delete();
    // Se desejar um feedback visual rápido, pode adicionar um SnackBar aqui:
    // if (mounted) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text('Sala removida.'), backgroundColor: Colors.grey[700]),
    //   );
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kScaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "Gerenciar Salas",
          style: TextStyle(color: kLightTextColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: kPrimaryColor,
        iconTheme: const IconThemeData(color: kLightTextColor),
        elevation: 1.0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // ##### CORREÇÃO AQUI: Stream restaurado para o original #####
        stream: _firestore.collection("salas").snapshots(),
        // ##########################################################
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: kPrimaryColor));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.meeting_room_outlined, size: 80, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  "Nenhuma sala cadastrada ainda.",
                  style: TextStyle(fontSize: 18.0, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  "Clique no botão '+' para adicionar.",
                  style: TextStyle(fontSize: 16.0, color: Colors.grey),
                ),
              ],
            ));
          }

          var salas = snapshot.data!.docs;

          // Ordenação manual no cliente, se desejado (opcional, já que removemos do Firebase query)
          // salas.sort((a, b) {
          //   var salaAData = a.data() as Map<String, dynamic>;
          //   var salaBData = b.data() as Map<String, dynamic>;
          //   int localCompare = (salaAData['local'] ?? '').compareTo(salaBData['local'] ?? '');
          //   if (localCompare != 0) return localCompare;
          //   return (salaAData['nome_da_sala'] ?? '').compareTo(salaBData['nome_da_sala'] ?? '');
          // });

          return ListView.builder(
            padding: const EdgeInsets.all(10.0),
            itemCount: salas.length,
            itemBuilder: (context, index) {
              var sala = salas[index];
              var salaData = sala.data() as Map<String, dynamic>;

              return Card(
                elevation: 2.0,
                margin:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 5.0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0)),
                color: kCardBackgroundColor,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 15.0),
                  leading: CircleAvatar(
                    backgroundColor: kPrimaryColor.withOpacity(0.1),
                    child: const Icon(Icons.meeting_room,
                        color: kPrimaryColor, size: 28),
                  ),
                  title: Text(
                    salaData["nome_da_sala"] ?? "Nome Indisponível",
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 17.0,
                        color: kDarkTextColor),
                  ),
                  subtitle: Text(
                    "Local: ${salaData["local"] ?? "Não especificado"}",
                    style:
                        TextStyle(fontSize: 14.0, color: Colors.grey.shade700),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined,
                            color: kAccentColor),
                        tooltip: "Editar",
                        onPressed: () => _adicionarOuEditarSala(
                          id: sala.id,
                          nome: salaData["nome_da_sala"],
                          local: salaData["local"],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline,
                            color: kErrorColor),
                        tooltip: "Remover",
                        onPressed: () => _removerSala(sala.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: kPrimaryColor,
        icon: const Icon(Icons.add, color: kLightTextColor),
        label: const Text("Nova Sala",
            style:
                TextStyle(color: kLightTextColor, fontWeight: FontWeight.w600)),
        onPressed: () => _adicionarOuEditarSala(),
        tooltip: 'Adicionar Nova Sala',
      ),
    );
  }
}
