import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sistema_mapeamento_de_materiais/Admin/admin_login.dart';
import 'package:sistema_mapeamento_de_materiais/pages/home.dart';
import 'package:sistema_mapeamento_de_materiais/pages/onboarding.dart';
import 'package:sistema_mapeamento_de_materiais/pages/signup.dart';

class LogIn extends StatefulWidget {
  const LogIn({super.key});

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  String? mail, password;
  TextEditingController emailcontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();

  final _formkey = GlobalKey<FormState>();

  userLogin() async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: mail!, password: password!);
      Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
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
                "Olá\nLogin!",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 32.0,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              padding: EdgeInsets.all(30.0),
              margin: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height / 4),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40))),
              child: Form(
                key: _formkey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("E-mail",
                        style: TextStyle(
                            fontSize: 23.0, fontWeight: FontWeight.w500)),
                    TextFormField(
                      controller: emailcontroller,
                      decoration: InputDecoration(
                          hintText: "E-mail",
                          prefixIcon: Icon(Icons.mail_outline)),
                    ),
                    SizedBox(height: 40.0),
                    Text("Senha",
                        style: TextStyle(
                            fontSize: 23.0, fontWeight: FontWeight.w500)),
                    TextFormField(
                      controller: passwordcontroller,
                      decoration: InputDecoration(
                          hintText: "Senha",
                          prefixIcon: Icon(Icons.password_outlined)),
                      obscureText: true,
                    ),
                    SizedBox(height: 30.0),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text("Esqueceu a Senha?",
                              style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.w500)),
                        ]),
                    SizedBox(height: 60.0),
                    GestureDetector(
                      onTap: () {
                        if (_formkey.currentState!.validate()) {
                          setState(() {
                            mail = emailcontroller.text;
                            password = passwordcontroller.text;
                          });
                          userLogin();
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
                            borderRadius: BorderRadius.circular(30)),
                        child: Center(
                            child: Text("Login",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24.0,
                                    fontWeight: FontWeight.bold))),
                      ),
                    ),
                    Spacer(),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text("Você não tem uma Conta?",
                              style: TextStyle(
                                  fontSize: 17.0,
                                  fontWeight: FontWeight.w500)),
                        ]),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SignUp()));
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text("Inscreva-se",
                              style: TextStyle(
                                  fontSize: 22.0,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.0),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text("Caso seja ADM",
                              style: TextStyle(
                                  fontSize: 17.0,
                                  fontWeight: FontWeight.w500)),
                        ]),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AdminLogin()));
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text("Login ADM",
                              style: TextStyle(
                                  fontSize: 22.0,
                                  fontWeight: FontWeight.bold)),
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
}
