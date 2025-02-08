import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sistema_mapeamento_de_materiais/Admin/booking_admin.dart';
import 'package:sistema_mapeamento_de_materiais/pages/login.dart';


class AdminLogin extends StatefulWidget {
  const AdminLogin({super.key});

  @override
  State<AdminLogin> createState() => _AdminLoginState();
}

class _AdminLoginState extends State<AdminLogin> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Stack(
          children: [
            Container(
              padding: EdgeInsets.only(top: 50.0, left: 30.0),
              height: MediaQuery.of(context).size.height / 2,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                Color(0xFF091057),
                Color(0xff1F509A),
                Color(0xFF311937)
              ])),
              child: Text(
                "Admin\nPainel",
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
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "E-mail",
                      style: TextStyle(
                          color: Color(0xFF091057),
                          fontSize: 23.0,
                          fontWeight: FontWeight.w500),
                    ),
                    TextFormField(
                      controller: emailController,
                      decoration: InputDecoration(
                          hintText: "Digite seu E-mail",
                          prefixIcon: Icon(Icons.mail_outline)),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Campo obrigatório";
                        }
                        if (!value.contains("@")) {
                          return "Digite um e-mail válido";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 40.0),
                    Text(
                      "Senha",
                      style: TextStyle(
                          color: Color(0xFF091057),
                          fontSize: 23.0,
                          fontWeight: FontWeight.w500),
                    ),
                    TextFormField(
                      controller: passwordController,
                      decoration: InputDecoration(
                          hintText: "Digite Sua Senha",
                          prefixIcon: Icon(Icons.password_outlined)),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Campo obrigatório";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 60.0),
                    GestureDetector(
                      onTap: () {
                        if (_formKey.currentState!.validate()) {
                          loginAdmin();
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
                            "Entrar",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          "Caso seja Professor",
                          style: TextStyle(
                            fontSize: 17.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LogIn()));
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            "Login Professor",
                            style: TextStyle(
                              fontSize: 22.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
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

  void loginAdmin() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email != "admin@ufrpe.br") {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          "Apenas o email admin@ufrpe.br pode acessar!",
          style: TextStyle(fontSize: 18.0, color: Colors.black),
        ),
      ));
      return;
    }

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => BookingAdmin()),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          e.code == 'user-not-found'
              ? "Nenhum usuário encontrado para esse E-mail"
              : e.code == 'wrong-password'
                  ? "Senha incorreta fornecida pelo usuário"
                  : "Erro ao realizar login",
          style: TextStyle(fontSize: 18.0, color: Colors.black),
        ),
      ));
    }
  }
}
