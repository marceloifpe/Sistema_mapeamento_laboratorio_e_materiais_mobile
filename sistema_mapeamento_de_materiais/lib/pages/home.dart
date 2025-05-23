import 'package:flutter/material.dart';
import 'package:sistema_mapeamento_de_materiais/pages/booking.dart';
import 'package:sistema_mapeamento_de_materiais/pages/bookingmaterial.dart';
import 'package:sistema_mapeamento_de_materiais/pages/login.dart'; // Importe a página de Login
import 'package:sistema_mapeamento_de_materiais/pages/reserva_qrcode_material.dart';
import 'package:sistema_mapeamento_de_materiais/pages/ver_reserva_material.dart';
import 'package:sistema_mapeamento_de_materiais/pages/ver_reserva_sala.dart';
import 'package:sistema_mapeamento_de_materiais/services/shared_pref.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String? name; // Nome do usuário

  // Cores consistentes com as outras telas
  static const Color kPrimaryColor = Color(0xFF091057);
  static const Color kAccentColor = Color(0xff1F509A);
  static const Color kLightTextColor =
      Colors.white; // Para texto em fundos escuros
  static const Color kDarkTextColor =
      Colors.black87; // Para texto em fundos claros
  static const Color kCardBackgroundColor = Colors.white;
  static const Color kScaffoldBackgroundColor =
      Color(0xFFF4F6F8); // Um cinza bem claro

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    name = await SharedpreferenceHelper().getUserName();
    if (mounted) {
      setState(() {});
    }
  }

  void _logout() async {
    // Adicionar um diálogo de confirmação para logout
    bool? confirmLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Logout'),
          content: const Text('Você tem certeza que deseja sair?'),
          actions: <Widget>[
            TextButton(
              child:
                  const Text('Cancelar', style: TextStyle(color: kAccentColor)),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              style: TextButton.styleFrom(backgroundColor: kPrimaryColor),
              child:
                  const Text('Sair', style: TextStyle(color: kLightTextColor)),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        );
      },
    );

    if (confirmLogout == true) {
      await SharedpreferenceHelper().clearUserData();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          // Para limpar a pilha de navegação
          context,
          MaterialPageRoute(builder: (context) => const LogIn()),
          (Route<dynamic> route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kScaffoldBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false, // Remove o botão de voltar automático
        title: const Text(
          "Mapeamento UFRPE", // Título mais conciso
          style: TextStyle(color: kLightTextColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: kPrimaryColor, // Cor primária na AppBar
        elevation: 2.0, // Sutil elevação
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_outlined,
                color: kLightTextColor), // Ícone de logout
            tooltip: 'Sair',
            onPressed: _logout,
          ),
        ],
      ),
      body: RefreshIndicator(
        // Permite puxar para atualizar os dados do usuário (se necessário no futuro)
        onRefresh: _loadUserData,
        color: kPrimaryColor,
        child: SingleChildScrollView(
          physics:
              const AlwaysScrollableScrollPhysics(), // Garante que o RefreshIndicator funcione mesmo com pouco conteúdo
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeSection(),
              const SizedBox(height: 25.0),
              const Text(
                "Serviços Disponíveis",
                style: TextStyle(
                    color: kDarkTextColor,
                    fontSize: 22.0, // Tamanho ajustado
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20.0),
              _buildServicesGrid(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    String displayName =
        name != null && name!.isNotEmpty ? name! : "Professor(a)";
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 25.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [kPrimaryColor, kAccentColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: kPrimaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            // Para o texto não estourar se o nome for muito grande
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Olá, $displayName!",
                  style: const TextStyle(
                      color: kLightTextColor,
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold),
                  overflow:
                      TextOverflow.ellipsis, // Caso o nome seja muito grande
                ),
                const SizedBox(height: 4.0),
                const Text(
                  "Seja bem-vindo(a) de volta.",
                  style: TextStyle(
                    color: kLightTextColor,
                    fontSize: 16.0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 15), // Espaço entre o texto e a imagem
          ClipRRect(
            borderRadius:
                BorderRadius.circular(30.0), // Imagem de usuário circular
            child: Image.asset(
              "images/usuario.png", // Mantenha sua imagem de usuário
              height: 60,
              width: 60,
              fit: BoxFit.cover,
              // Em caso de erro ao carregar a imagem, mostrar um ícone
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  child:
                      Icon(Icons.person, color: Colors.grey.shade700, size: 35),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesGrid() {
    // Lista de serviços para facilitar a manutenção
    final List<Map<String, dynamic>> services = [
      {
        "title": "Reservar Material",
        "imagePath": "images/projetor.png", // Use seus caminhos de imagem
        "destination": BookingMaterial(service: "Material"),
        "icon": Icons.build_circle_outlined, // Ícone de exemplo
      },
      {
        "title": "Reservar Sala",
        "imagePath": "images/sala.png",
        "destination": Booking(service: "Sala"),
        "icon": Icons.meeting_room_outlined,
      },
      {
        "title": "Minhas Reservas\n(Material)",
        "imagePath": "images/projetor.png",
        "destination": VerReservaMaterial(service: "Material"),
        "icon": Icons.list_alt_outlined,
      },
      {
        "title": "Minhas Reservas\n(Sala)",
        "imagePath": "images/sala.png",
        "destination": VerReservaSala(service: "Sala"),
        "icon": Icons.event_available_outlined,
      },
      {
        "title": "Escanear Material\n(QRCode)",
        "imagePath": "images/qr.png",
        // Verifique se ReservaMaterial é a tela correta para QR Code ou se seria ReservaQrCodeMaterial
        "destination": ReservaMaterial(
            service: "Material"), // Ajustado para a tela correta de QRCode
        "icon": Icons.qr_code_scanner_outlined,
      },
      // Adicione mais serviços aqui se necessário
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // 2 colunas
        crossAxisSpacing: 15.0,
        mainAxisSpacing: 15.0,
        childAspectRatio:
            0.95, // Ajuste para o conteúdo caber bem (mais altura)
      ),
      itemCount: services.length,
      itemBuilder: (context, index) {
        final service = services[index];
        return _buildServiceCard(
          service["title"],
          service[
              "imagePath"], // Ou service["icon"] se preferir usar ícones no card
          service["destination"],
          service["icon"], // Passando o ícone
        );
      },
    );
  }

  Widget _buildServiceCard(
      String title, String imagePath, Widget? destination, IconData iconData) {
    return Card(
      // Usar Card para elevação e bordas mais fáceis
      elevation: 3.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      color: kCardBackgroundColor,
      child: InkWell(
        // Adiciona o efeito de ripple
        borderRadius:
            BorderRadius.circular(15.0), // Para o ripple seguir a borda do card
        onTap: () {
          if (destination != null) {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => destination));
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0), // Padding interno do card
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Alternativa: Usar Ícone em vez de imagem, ou como fallback
              // CircleAvatar(
              //   radius: 30,
              //   backgroundColor: kAccentColor.withOpacity(0.1),
              //   child: Icon(iconData, size: 30, color: kAccentColor),
              // ),
              Image.asset(imagePath,
                  height: 65, // Ajuste o tamanho da imagem
                  width: 65,
                  fit: BoxFit.contain, // 'contain' para ver a imagem toda
                  errorBuilder: (context, error, stackTrace) {
                // Fallback para imagem
                return CircleAvatar(
                  radius: 30,
                  backgroundColor: kAccentColor.withOpacity(0.1),
                  child: Icon(iconData, size: 30, color: kAccentColor),
                );
              }),
              const SizedBox(height: 12.0),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: kDarkTextColor, // Texto escuro no card claro
                  fontSize: 15.0, // Tamanho ajustado
                  fontWeight: FontWeight.w600, // Um pouco mais de peso
                ),
                maxLines: 2, // Para títulos com quebra de linha
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
