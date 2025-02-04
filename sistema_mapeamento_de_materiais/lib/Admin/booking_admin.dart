import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sistema_mapeamento_de_materiais/Admin/gerenciar_salas.dart';
import 'package:sistema_mapeamento_de_materiais/services/database.dart';
import 'package:sistema_mapeamento_de_materiais/pages/login.dart';
import 'package:sistema_mapeamento_de_materiais/Admin/gerenciar_salas.dart'; // Importa a tela de Gerenciar Salas
import 'package:sistema_mapeamento_de_materiais/Admin/gerenciar_materiais.dart';

class BookingAdmin extends StatefulWidget {
  @override
  State<BookingAdmin> createState() => _BookingAdminState();
}

class _BookingAdminState extends State<BookingAdmin> {
  String? adminName = "Administrador"; // Nome do administrador

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      appBar: AppBar(
        title: Text('Booking Admin'),
        backgroundColor: Color(0xff1F509A),
      ),
      body: Container(
        margin: EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Olá,",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 24.0,
                          fontWeight: FontWeight.w500),
                    ),
                    Text(
                      adminName ?? "Administrador",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                // ClipRRect(
                //   borderRadius: BorderRadius.circular(10),
                //   child: Image.asset(
                //     "assets/images/usuario.png",
                //     height: 60,
                //     width: 60,
                //     fit: BoxFit.cover,
                //   ),
                // ),
              ],
            ),
            SizedBox(height: 20.0),
            Divider(color: Colors.black38),
            SizedBox(height: 20.0),
            Text(
              "Painel Administrativo",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20.0),
            _buildAdminOptions(),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminOptions() {
    return Column(
      children: [
        Row(
          children: [
            _buildOptionCard(
              title: "Gerenciar Materiais",
              icon: Icons.inventory,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => GerenciarMateriaisPage()),
                );
              },
            ),
            SizedBox(width: 20.0),
            _buildOptionCard(
              title: "Gerenciar Salas",
              icon: Icons.meeting_room,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GerenciarSalasPage()),
                );
              },
            ),
          ],
        ),
        SizedBox(height: 20.0),
        Row(
          children: [
            _buildOptionCard(
              title: "Relatórios",
              icon: Icons.bar_chart,
              onTap: () {
                // Implementar funcionalidade
              },
            ),
            SizedBox(width: 20.0),
            _buildOptionCard(
              title: "Configurações",
              icon: Icons.settings,
              onTap: () {
                // Implementar funcionalidade
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOptionCard({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Flexible(
      fit: FlexFit.tight,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 150,
          decoration: BoxDecoration(
            color: Color(0xff1F509A),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 50, color: Colors.white),
              SizedBox(height: 10.0),
              Text(
                title,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
