import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class VerReservaSala extends StatefulWidget {
  final String? service;

  VerReservaSala({this.service});

  @override
  _VerReservaSalaState createState() => _VerReservaSalaState();
}

class _VerReservaSalaState extends State<VerReservaSala> {
  Stream<QuerySnapshot>? reservasStream;

  getUserReservations() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        print("Email do usuário logado: ${user.email}");

        QuerySnapshot userQuery = await FirebaseFirestore.instance
            .collection('usuarios')
            .where('Email', isEqualTo: user.email)
            .limit(1)
            .get();

        if (userQuery.docs.isNotEmpty) {
          DocumentSnapshot userDoc = userQuery.docs.first;
          String usuarioId = userDoc["Id"];
          print("ID do usuário: $usuarioId");

          setState(() {
            reservasStream = FirebaseFirestore.instance
                .collection('reservas') // Alterado para coleção 'reservas'
                .where('usuarios_id', isEqualTo: usuarioId)
                .snapshots();
          });
        } else {
          print("Usuário não encontrado");
        }
      } else {
        print("Nenhum usuário logado");
      }
    } catch (e) {
      print("Erro ao buscar reservas: $e");
    }
  }

  @override
  void initState() {
    getUserReservations();
    super.initState();
  }

  String formatTimestamp(dynamic value) {
    if (value == null) return "Data não disponível";
    if (value is Timestamp) {
      return DateFormat('dd/MM/yyyy HH:mm').format(value.toDate());
    }
    return "Formato inválido";
  }

  Widget allReservas() {
    return StreamBuilder(
      stream: reservasStream,
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.data!.docs.isEmpty) {
          return Center(child: Text("Nenhuma reserva de sala encontrada"));
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
            reservaText("Sala: ", data["sala"] ?? "Não informado"),
            reservaText("Local: ", data["local"] ?? "Não informado"),
            //reservaText("ID da Sala: ", data["salas_id"] ?? "Não informado"),
            reservaText(
                "Data da Reserva: ", formatTimestamp(data["data_reserva"])),
            reservaText(
                "Data da Devolução: ", formatTimestamp(data["data_devolucao"])),
            reservaText("Data da Solicitação: ",
                formatTimestamp(data["data_solicitacao"])),
          ],
        ),
      ),
    );
  }

  Widget reservaText(String title, String value) {
    return Text("$title$value",
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Minhas Reservas de Sala")),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: allReservas(),
      ),
    );
  }
}
