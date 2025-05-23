import 'dart:io'; // Mantido caso haja algum uso indireto ou futuro.
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sistema_mapeamento_de_materiais/Admin/TelaQrCode.dart';

class GerenciarMateriaisPage extends StatefulWidget {
  const GerenciarMateriaisPage({super.key});

  @override
  _GerenciarMateriaisPageState createState() => _GerenciarMateriaisPageState();
}

class _GerenciarMateriaisPageState extends State<GerenciarMateriaisPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Cores consistentes com o tema do aplicativo
  static const Color kPrimaryColor = Color(0xFF091057);
  static const Color kAccentColor = Color(0xff1F509A);
  static const Color kLightTextColor = Colors.white;
  static const Color kDarkTextColor = Colors.black87;
  static const Color kScaffoldBackgroundColor = Color(0xFFF4F6F8);
  static const Color kCardBackgroundColor = Colors.white;
  static const Color kErrorColor = Colors.redAccent;
  // static const Color kSuccessColor = Colors.green; // Removido pois o snackbar de sucesso na deleção foi removido

  void _adicionarOuEditarMaterial({
    String? id,
    String? nome,
    // String? qrCodeExistente, // Não é mais necessário passar para o diálogo, pois o QR não é editável aqui
  }) {
    String novoNome = nome ?? "";
    TextEditingController controller = TextEditingController(text: nome);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          title: Text(
            id == null ? "Adicionar Novo Material" : "Editar Material",
            style: const TextStyle(
                color: kPrimaryColor, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: "Nome do Material",
                  labelStyle: const TextStyle(color: kAccentColor),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: kPrimaryColor, width: 2.0),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  prefixIcon: const Icon(Icons.label_important_outline,
                      color: kAccentColor),
                ),
                controller: controller,
                style: const TextStyle(color: kDarkTextColor),
              ),
            ],
          ),
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
                novoNome = controller.text.trim();
                if (novoNome.isNotEmpty) {
                  if (id == null) {
                    // Adicionar novo material
                    DocumentReference docRef =
                        await _firestore.collection("materiais").add({
                      "nome_do_material": novoNome,
                      "reservado": false,
                      "qr_code": "", // QR Code será o ID do documento
                    });
                    await docRef.update({
                      // Lógica original para qr_code
                      "qr_code": docRef.id,
                    });
                  } else {
                    // Editar material existente
                    await _firestore.collection("materiais").doc(id).update({
                      "nome_do_material": novoNome,
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

  // Lógica original de _removerMaterial restaurada
  void _removerMaterial(String id) {
    _firestore.collection("materiais").doc(id).delete();
    // Opcional: Adicionar um SnackBar de feedback aqui se desejar, mas mantendo a lógica original sem diálogo de confirmação.
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(content: Text('Material removido.'), backgroundColor: Colors.grey[700]),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kScaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "Gerenciar Materiais",
          style: TextStyle(color: kLightTextColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: kPrimaryColor,
        iconTheme: const IconThemeData(color: kLightTextColor),
        elevation: 1.0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection("materiais")
            .orderBy("nome_do_material")
            .snapshots(),
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
                Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  "Nenhum material cadastrado ainda.",
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

          var materiais = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(10.0),
            itemCount: materiais.length,
            itemBuilder: (context, index) {
              var material = materiais[index];
              var materialData = material.data() as Map<String, dynamic>;
              // Lógica original para obter qrCodeData
              String qrCodeData = materialData["qr_code"] as String? ?? "";

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
                    child: const Icon(Icons.build_circle_outlined,
                        color: kPrimaryColor, size: 28),
                  ),
                  title: Text(
                    materialData["nome_do_material"] ?? "Nome Indisponível",
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 17.0,
                        color: kDarkTextColor),
                  ),
                  // Subtítulo restaurado para o formato original de exibição do QR Code
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
                          child: Padding(
                            // Adicionado Padding para afastar um pouco do título
                            padding: const EdgeInsets.only(top: 8.0),
                            child: SizedBox(
                              height: 60, // Tamanho original
                              width: 60, // Tamanho original
                              child: QrImageView(
                                data: qrCodeData,
                                version: QrVersions.auto,
                                size: 60.0, // Tamanho original
                                gapless: false,
                                // Você pode adicionar um errorStateBuilder se quiser
                                // errorStateBuilder: (cxt, err) {
                                //   return const Center(child: Text("QR Indisponível", style: TextStyle(fontSize: 10)));
                                // },
                              ),
                            ),
                          ),
                        )
                      : null, // Se não houver qrCodeData, o subtítulo é nulo (como no original)
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined,
                            color: kAccentColor),
                        tooltip: "Editar",
                        onPressed: () => _adicionarOuEditarMaterial(
                          id: material.id,
                          nome: materialData["nome_do_material"],
                          // qrCodeExistente não é mais necessário aqui, pois não é editável
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline,
                            color: kErrorColor),
                        tooltip: "Remover",
                        // Chamando _removerMaterial diretamente, sem diálogo de confirmação
                        onPressed: () => _removerMaterial(material.id),
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
        label: const Text("Novo Material",
            style:
                TextStyle(color: kLightTextColor, fontWeight: FontWeight.w600)),
        onPressed: () => _adicionarOuEditarMaterial(),
        tooltip: 'Adicionar Novo Material',
      ),
    );
  }
}
