import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:sistema_mapeamento_de_materiais/Admin/booking_admin.dart';

class AdminLogin extends StatefulWidget {
  const AdminLogin({super.key});

  @override
  State<AdminLogin> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<AdminLogin> {
  TextEditingController nomedeusuariocontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();

  FocusNode usernameFocusNode = FocusNode();
  FocusNode passwordFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Stack(
          children: [
            Container(
              padding: EdgeInsets.only(
                top: 50.0,
                left: 30.0,
              ),
              height: MediaQuery.of(context).size.height / 2,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                Color(0xFF091057),
                Color(0xff1F509A),
                Color(0xFF311937)
              ])),
              child: Text(
                "Painel do\nAdministradores!",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 32.0,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              padding: EdgeInsets.only(
                  top: 40.0, left: 30.0, right: 30.0, bottom: 30.0),
              margin:
                  EdgeInsets.only(top: MediaQuery.of(context).size.height / 4),
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40))),
              child: Form(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Nome de Usuario",
                      style: TextStyle(
                          color: Color(0xFF091057),
                          fontSize: 23.0,
                          fontWeight: FontWeight.w500),
                    ),
                    TextFormField(
                      controller: nomedeusuariocontroller,
                      focusNode: usernameFocusNode,
                      decoration: InputDecoration(
                          hintText: "Nome de Usuario",
                          prefixIcon: Icon(Icons.mail_outline)),
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(passwordFocusNode);
                      },
                    ),
                    SizedBox(
                      height: 40.0,
                    ),
                    Text(
                      "Senha",
                      style: TextStyle(
                          color: Color(0xFF091057),
                          fontSize: 23.0,
                          fontWeight: FontWeight.w500),
                    ),
                    TextFormField(
                      controller: passwordcontroller,
                      focusNode: passwordFocusNode,
                      decoration: InputDecoration(
                        hintText: "Senha",
                        prefixIcon: Icon(Icons.password_outlined),
                      ),
                      obscureText: true,
                      onFieldSubmitted: (_) {
                        if (nomedeusuariocontroller.text.isEmpty ||
                            passwordcontroller.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content:
                                Text("Por favor, preencha ambos os campos."),
                          ));
                        } else {
                          _loginAdmin(); // Agora chamando a função diretamente
                        }
                      },
                    ),
                    SizedBox(
                      height: 60.0,
                    ),
                    GestureDetector(
                      onTap: () {
                        if (nomedeusuariocontroller.text.isEmpty ||
                            passwordcontroller.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content:
                                Text("Por favor, preencha ambos os campos."),
                          ));
                        } else {
                          _loginAdmin(); // Chamando a função diretamente
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 10.0),
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [
                            Color(0xFF091057),
                            Color(0xff1F509A),
                            Color(0xFF311937)
                          ]),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Center(
                            child: Text(
                          "LOGIN",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                          ),
                        )),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    usernameFocusNode.dispose();
    passwordFocusNode.dispose();
    super.dispose();
  }

  void _loginAdmin() async {
    try {
      if (nomedeusuariocontroller.text.trim().isEmpty ||
          passwordcontroller.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            "Por favor, preencha ambos os campos.",
            style: TextStyle(fontSize: 20.0),
          ),
        ));
        return;
      }

      var snapshot = await FirebaseFirestore.instance.collection("Admin").get();
      bool idEncontrado = false;

      for (var result in snapshot.docs) {
        final adminData = result.data();
        if (adminData['id'] == nomedeusuariocontroller.text.trim()) {
          idEncontrado = true;

          if (adminData['Senha'] == passwordcontroller.text.trim()) {
            // Log bem-sucedido
            print("Login bem-sucedido! Redirecionando...");

            // Garantindo a navegação no contexto correto
            Future.delayed(Duration(seconds: 1), () {
              // Usando `Navigator.of(context)` para a navegação
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => BookingAdmin()),
              );
            });

            return;
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                "Senha incorreta.",
                style: TextStyle(fontSize: 20.0),
              ),
            ));
            return;
          }
        }
      }

      if (!idEncontrado) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            "Seu ID não está correto!",
            style: TextStyle(fontSize: 20.0),
          ),
        ));
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          "Erro ao realizar o login. Tente novamente.",
          style: TextStyle(fontSize: 20.0),
        ),
      ));
    }
  }
}
