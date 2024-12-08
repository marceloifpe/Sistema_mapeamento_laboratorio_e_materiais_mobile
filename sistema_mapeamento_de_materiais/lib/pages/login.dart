import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
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
  TextEditingController emailcontroller = new TextEditingController();
  TextEditingController passwordcontroller = new TextEditingController();

  final _formkey = GlobalKey<FormState>();

  userLogin() async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: mail!, password: password!);
      // ignore: use_build_context_synchronously
      Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'Usuário-não-encontrado') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
          "Nenhum usuário encontrado para esse E-mail",
          style: TextStyle(fontSize: 18.0, color: Colors.black),
        )));
      } else if (e.code == 'Senha-Incorreta') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
          "Senha Incorreta fornecida pelo Usuário",
          style: TextStyle(fontSize: 18.0, color: Colors.black),
        )));
      }
    }
  }

  @override
  Widget build(BuildContext) {
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
                "Olá\nLogin!",
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
                key: _formkey,
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor informe o E-mail';
                        }
                        return null;
                      },
                      controller: emailcontroller,
                      decoration: InputDecoration(
                          hintText: "E-mail",
                          prefixIcon: Icon(Icons.mail_outline)),
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Campo obrigatório';
                        }
                        return null;
                      },
                      controller: passwordcontroller,
                      decoration: InputDecoration(
                        hintText: "Senha",
                        prefixIcon: Icon(Icons.password_outlined),
                      ),
                      obscureText: true,
                    ),
                    SizedBox(
                      height: 30.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          "Esqueceu a Senha?",
                          style: TextStyle(
                              color: Color(0xff1F509A),
                              fontSize: 18.0,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 60.0,
                    ),
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
                            child: Text(
                          "Login",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold),
                        )),
                      ),
                    ),
                    Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          "Você não tem uma Conta?",
                          style: TextStyle(
                              color: Color(0xff1F509A),
                              fontSize: 17.0,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => SignUp()));
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            "Inscreva-se",
                            style: TextStyle(
                                color: Color(0xff1F509A),
                                fontSize: 22.0,
                                fontWeight: FontWeight.bold),
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
}
