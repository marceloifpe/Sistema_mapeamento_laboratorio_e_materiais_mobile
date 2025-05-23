import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart'; // Not directly used in this UI logic
// import 'package:firebase_core/firebase_core.dart'; // Not directly used here
import 'package:sistema_mapeamento_de_materiais/Admin/admin_login.dart';
import 'package:sistema_mapeamento_de_materiais/Admin/gerenciar_salas.dart';
import 'package:sistema_mapeamento_de_materiais/Admin/ver_relatorio.dart';
// import 'package:sistema_mapeamento_de_materiais/services/database.dart'; // Not directly used here
// import 'package:sistema_mapeamento_de_materiais/pages/login.dart'; // Not used here
import 'package:sistema_mapeamento_de_materiais/Admin/gerenciar_materiais.dart';
import 'package:sistema_mapeamento_de_materiais/services/shared_pref.dart';

class BookingAdmin extends StatefulWidget {
  // Adicionado construtor com super.key
  const BookingAdmin({super.key});

  @override
  State<BookingAdmin> createState() => _BookingAdminState();
}

class _BookingAdminState extends State<BookingAdmin> {
  final String adminName =
      "Administrador"; // Nome do administrador (mantido estático)

  // Cores consistentes com o tema do aplicativo
  static const Color kPrimaryColor = Color(0xFF091057);
  static const Color kAccentColor = Color(0xff1F509A);
  static const Color kLightTextColor = Colors.white;
  static const Color kDarkTextColor = Colors.black87;
  static const Color kCardBackgroundColor = Colors.white;
  static const Color kScaffoldBackgroundColor = Color(0xFFF4F6F8);

  // Função para realizar o logout
  void _logout() async {
    // Adicionar um diálogo de confirmação para logout
    bool? confirmLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Logout'),
          content: const Text(
              'Você tem certeza que deseja sair do painel administrativo?'),
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
      await SharedpreferenceHelper().clearUserData(); // Limpa SharedPreferences
      await FirebaseAuth.instance.signOut(); // Logout no Firebase

      if (mounted) {
        // Verificar se o widget ainda está montado
        Navigator.pushAndRemoveUntil(
          // Limpa a pilha de navegação
          context,
          MaterialPageRoute(builder: (context) => const AdminLogin()),
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
        title: const Text(
          'Painel Administrativo', // Título mais apropriado
          style: TextStyle(color: kLightTextColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: kPrimaryColor, // Usando kPrimaryColor
        automaticallyImplyLeading: false,
        elevation: 2.0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_outlined, color: kLightTextColor),
            tooltip: 'Sair',
            onPressed: _logout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        // Permite rolagem se o conteúdo exceder a tela
        padding: const EdgeInsets.all(20.0), // Padding geral
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeSection(), // Seção de boas-vindas com imagem
            const SizedBox(height: 25.0),
            const Text(
              "Gerenciamento", // Título da seção de opções
              style: TextStyle(
                  color: kDarkTextColor,
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20.0),
            _buildAdminOptions(), // Opções administrativas em cards
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Olá, $adminName!",
                  style: const TextStyle(
                      color: kLightTextColor,
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4.0),
                const Text(
                  "Acesso ao painel de controle.",
                  style: TextStyle(
                    color: kLightTextColor,
                    fontSize: 16.0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 15),
          ClipRRect(
            borderRadius: BorderRadius.circular(30.0),
            child: Image.asset(
              // Você precisará adicionar esta imagem
              "images/usuario.png", // Caminho para a imagem do avatar do admin
              height: 60,
              width: 60,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // Fallback caso a imagem não seja encontrada
                return Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  child: Icon(Icons.admin_panel_settings_outlined,
                      color: Colors.grey.shade700, size: 35),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminOptions() {
    // Lista de opções para facilitar a manutenção
    final List<Map<String, dynamic>> adminOptions = [
      {
        "title": "Gerenciar Materiais",
        "icon": Icons
            .inventory_2_outlined, // Ícones Outlined para um visual mais leve
        "destination": () => GerenciarMateriaisPage(),
      },
      {
        "title": "Gerenciar Salas",
        "icon": Icons.meeting_room_outlined,
        "destination": () => GerenciarSalasPage(),
      },
      {
        "title": "Relatórios",
        "icon": Icons.bar_chart_outlined,
        "destination": () => VerRelatorioPage(),
      },
      {
        "title": "Configurações",
        "icon": Icons.settings_outlined,
        "destination": () {
          // Placeholder: Mostrar SnackBar ou navegar para tela de config
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Tela de Configurações (a implementar)"),
              backgroundColor: kAccentColor));
        },
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // 2 colunas
        crossAxisSpacing: 15.0,
        mainAxisSpacing: 15.0,
        childAspectRatio: 1.0, // Ajuste para o conteúdo caber bem
      ),
      itemCount: adminOptions.length,
      itemBuilder: (context, index) {
        final option = adminOptions[index];
        return _buildOptionCard(
          title: option["title"],
          icon: option["icon"],
          onTap: () {
            // Navega para a tela de destino
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => option["destination"]()),
            );
          },
        );
      },
    );
  }

  Widget _buildOptionCard({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      // Usar Card para elevação e bordas
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      color: kCardBackgroundColor, // Fundo branco para os cards
      child: InkWell(
        // Efeito de ripple no toque
        borderRadius: BorderRadius.circular(15.0),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 48, color: kPrimaryColor), // Ícone com cor primária
              const SizedBox(height: 12.0),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: kDarkTextColor, // Texto escuro
                    fontSize: 16.0, // Tamanho ajustado
                    fontWeight: FontWeight.w600), // Peso da fonte
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
