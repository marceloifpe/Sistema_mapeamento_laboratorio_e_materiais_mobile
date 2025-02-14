import 'package:flutter/material.dart';
import 'package:sistema_mapeamento_de_materiais/pages/booking.dart';
import 'package:sistema_mapeamento_de_materiais/pages/bookingmaterial.dart';
import 'package:sistema_mapeamento_de_materiais/pages/login.dart'; // Importe a página de Login
import 'package:sistema_mapeamento_de_materiais/pages/reserva_qrcode_material.dart';
import 'package:sistema_mapeamento_de_materiais/services/shared_pref.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String? name;

  getthedatafromsharedpref() async {
    name = await SharedpreferenceHelper().getUserName();
    setState(() {});
  }

  getontheload() async {
    await getthedatafromsharedpref();
    setState(() {});
  }

  @override
  void initState() {
    getontheload();
    super.initState();
  }

  void logout() async {
    await SharedpreferenceHelper().clearUserData();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LogIn()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Sistema de Mapeamento de Materiais"),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: logout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(top: 50.0, left: 20.0, right: 20.0, bottom: 20.0),
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
                      "Seja Bem-vindo Professor",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    "images/usuario.png",
                    height: 60,
                    width: 60,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.0),
            Divider(color: Colors.black38),
            SizedBox(height: 20.0),
            Text(
              "Serviços",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20.0),
            GridView.count(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 20.0,
              mainAxisSpacing: 20.0,
              childAspectRatio: 1.0,
              children: [
                buildServiceCard("Material", "images/projetor.png", BookingMaterial(service: "Material")),
                buildServiceCard("Sala", "images/sala.png", Booking(service: "Sala")),
                buildServiceCard("Ver Reserva Material", "images/projetor.png", null),
                buildServiceCard("Ver Reserva Sala", "images/sala.png", null),
                buildServiceCard("Escanear QrCode", "images/qr.jpeg", ReservaMaterial(service:"Material")),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildServiceCard(String title, String imagePath, Widget? destination) {
    return GestureDetector(
      onTap: () {
        if (destination != null) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => destination));
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xff1F509A),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(imagePath, height: 80, width: 80, fit: BoxFit.cover),
            SizedBox(height: 10.0),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}