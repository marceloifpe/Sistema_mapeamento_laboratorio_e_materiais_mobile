import 'package:flutter/material.dart';
import 'package:sistema_mapeamento_de_materiais/pages/booking.dart';
import 'package:sistema_mapeamento_de_materiais/pages/bookingmaterial.dart';
import 'package:sistema_mapeamento_de_materiais/pages/login.dart'; // Importe a página de Login
import 'package:sistema_mapeamento_de_materiais/services/shared_pref.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String? name;

  // Função para obter o nome do usuário do SharedPreferences
  getthedatafromsharedpref() async {
    name = await SharedpreferenceHelper().getUserName();
    setState(() {});
  }

  // Função chamada ao inicializar a tela
  getontheload() async {
    await getthedatafromsharedpref();
    setState(() {});
  }

  @override
  void initState() {
    getontheload();
    super.initState();
  }

  // Função para realizar o logout e redirecionar para a tela de login
  void logout() async {
    // Limpa o SharedPreferences (se necessário)
    await SharedpreferenceHelper().clearUserData();

    // Redireciona para a página de login
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LogIn()), // Substitua "LoginPage" pelo nome da sua tela de login
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      appBar: AppBar(
        automaticallyImplyLeading: false, // Remove o botão de "back"
        title: Text("Sistema de Mapeamento de Materiais"),
        actions: [
          // Adiciona o botão de sair na AppBar
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: logout, // Chama a função de logout quando pressionado
          ),
        ],
      ),
      body: Container(
        margin: EdgeInsets.only(top: 50.0, left: 20.0, right: 20.0),
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
                    // Exibe o nome do usuário se disponível
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
                    ))
              ],
            ),
            SizedBox(
              height: 20.0,
            ),
            Divider(
              color: Colors.black38,
            ),
            SizedBox(
              height: 20.0,
            ),
            Text(
              "Serviços",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 20.0,
            ),
            Row(
              children: [
                Flexible(
                  fit: FlexFit.tight,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => BookingMaterial(
                                    service: "Material",
                                  ))); // Navega para a tela de material
                    },
                    child: Container(
                        height: 150,
                        decoration: BoxDecoration(
                            color: Color(0xff1F509A),
                            borderRadius: BorderRadius.circular(20)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset("images/projetor.png",
                                height: 80, width: 80, fit: BoxFit.cover),
                            SizedBox(
                              height: 10.0,
                            ),
                            Text(
                              "Material",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        )),
                  ),
                ),
                SizedBox(
                  width: 20.0,
                ),
                Flexible(
                  fit: FlexFit.tight,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Booking(
                                    service: "Sala",
                                  ))); // Navega para a tela de sala
                    },
                    child: Container(
                        height: 150,
                        decoration: BoxDecoration(
                            color: Color(0xff1F509A),
                            borderRadius: BorderRadius.circular(20)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset("images/sala.png",
                                height: 80, width: 80, fit: BoxFit.cover),
                            SizedBox(
                              height: 10.0,
                            ),
                            Text(
                              "Sala",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        )),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 20.0,
            ),
            Row(
              children: [
                Flexible(
                  fit: FlexFit.tight,
                  child: Container(
                      height: 150,
                      decoration: BoxDecoration(
                          color: Color(0xff1F509A),
                          borderRadius: BorderRadius.circular(20)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset("images/projetor.png",
                              height: 80, width: 80, fit: BoxFit.cover),
                          SizedBox(
                            height: 10.0,
                          ),
                          Text(
                            "Ver Reserva Material",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      )),
                ),
                SizedBox(
                  width: 20.0,
                ),
                Flexible(
                  fit: FlexFit.tight,
                  child: Container(
                      height: 150,
                      decoration: BoxDecoration(
                          color: Color(0xff1F509A),
                          borderRadius: BorderRadius.circular(20)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset("images/sala.png",
                              height: 80, width: 80, fit: BoxFit.cover),
                          SizedBox(
                            height: 10.0,
                          ),
                          Text(
                            "Ver Reserva Sala",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      )),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
