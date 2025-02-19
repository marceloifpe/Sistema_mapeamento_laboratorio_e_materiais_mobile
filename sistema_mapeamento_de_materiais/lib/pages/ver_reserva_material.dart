
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sistema_mapeamento_de_materiais/services/database.dart'; // Importe o DatabaseMethods
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Para formatação de datas


class VerReservaMaterial extends StatefulWidget {
  final String? service;

  VerReservaMaterial({this.service});

  @override
  _VerReservaMaterialState createState() => _VerReservaMaterialState();
}

class _VerReservaMaterialState extends State<VerReservaMaterial> {
  Stream<QuerySnapshot>? reservasStream;

  // Função para buscar o ID do usuário salvo no Firestore e, em seguida, as reservas
  getUserReservations() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        print("Email do usuário logado: ${user.email}");

        // Buscar o ID salvo na coleção 'usuarios' que corresponde ao usuário autenticado
        QuerySnapshot userQuery = await FirebaseFirestore.instance
            .collection('usuarios')
            .where('Email', isEqualTo: user.email) // Aqui busca pelo UID do usuário autenticado
            .limit(1)
            .get();

        if (userQuery.docs.isNotEmpty) {
          DocumentSnapshot userDoc = userQuery.docs.first;
          String usuarioId = userDoc["Id"]; // Pega o ID correto da coleção 'usuarios'
          print("ID do usuário encontrado no Firestore: $usuarioId");

          // Buscar as reservas associadas a esse ID
          setState(() {
            reservasStream = FirebaseFirestore.instance
                .collection('reserva')
                .where('usuarios_id', isEqualTo: usuarioId) // Agora faz sentido
                .snapshots();
          });
        } else {
          print("Usuário não encontrado na coleção 'usuarios'.");
        }
      } else {
        print("Nenhum usuário logado.");
      }
    } catch (e) {
      print("Erro ao buscar reservas: $e");
    }
  }

  @override
  void initState() {
    getUserReservations(); // Carrega as reservas ao iniciar a tela
    super.initState();
  }

  // Função para formatar Timestamp
  String formatTimestamp(dynamic value) {
    if (value == null) return "Data não disponível";
    if (value is Timestamp) {
      return DateFormat('dd/MM/yyyy HH:mm').format(value.toDate());
    }
    return "Formato de data inválido";
  }

  // Exibir reservas
  Widget allReservas() {
    return StreamBuilder(
      stream: reservasStream,
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.data!.docs.isEmpty) {
          return Center(child: Text("Nenhuma reserva disponível"));
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot ds = snapshot.data!.docs[index];
              return reservaCard(ds);
            },
          );
        }
      },
    );
  }

  // Card de exibição das reservas
  Widget reservaCard(DocumentSnapshot ds) {
    Map<String, dynamic> data = ds.data() as Map<String, dynamic>;
    return Card(
      elevation: 8.0,
      margin: EdgeInsets.all(10),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            reservaText("Material: ", data["material_nome"] ?? "Não informado"),
            reservaText("Data da Reserva: ", formatTimestamp(data["data_reserva"])),
            reservaText("Data da Devolução: ", formatTimestamp(data["data_devolucao"])),
            reservaText("Data da Solicitação: ", formatTimestamp(data["data_solicitacao"])),
          ],
        ),
      ),
    );
  }

  // Widget de texto formatado
  Widget reservaText(String title, String value) {
    return Text("$title$value",
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Minhas Reservas")),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: allReservas(),
      ),
    );
  }
}
