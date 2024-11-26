import 'package:flutter/material.dart';
import 'package:sistema_mapeamento_de_materiais/pages/home.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}


class _OnboardingState extends State<Onboarding> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      body: Container(
        margin: EdgeInsets.only(top: 120.0),
        child: Column(
          children: [
            Image.asset("images/ufrpe.png"),
            SizedBox(height: 50.0,),
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=> Home()));
              },
              child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                  decoration: BoxDecoration(
                      color: Color(0xFF091057),
                      borderRadius: BorderRadius.circular(30)),
                  child: Text(
                    "Agende o seu material",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22.0,
                        fontWeight: FontWeight.bold),
                  ),
                ),
            )
          ],
        ),
      ),
    );
  }
}
