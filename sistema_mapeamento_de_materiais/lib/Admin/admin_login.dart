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
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _obscurePassword = true;

  // Cores consistentes
  static const Color kPrimaryColor = Color(0xFF091057);
  static const Color kAccentColor = Color(0xff1F509A);
  static const Color kGradientEndColor = Color(0xFF311937);

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> loginAdmin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.toLowerCase() != "admin@ufrpe.br") {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Colors.orangeAccent,
          content: Text(
            "Acesso restrito ao e-mail de administrador.",
            style: TextStyle(fontSize: 18.0, color: Colors.white),
          ),
        ));
        setState(() {
          _isLoading = false;
        });
      }
      return;
    }

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => BookingAdmin()), // CONST REMOVIDO AQUI
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      String message;
      if (e.code == 'user-not-found') {
        message = "Administrador não encontrado para este e-mail.";
      } else if (e.code == 'wrong-password') {
        message = "Senha incorreta para o administrador.";
      } else if (e.code == 'invalid-email') {
        message = "O formato do e-mail é inválido.";
      } else if (e.code == 'too-many-requests') {
        message = "Muitas tentativas de login. Tente novamente mais tarde.";
      } else {
        message = "Erro ao realizar login de administrador.";
        print(
            "Firebase Auth Exception (Admin Login): ${e.message} (${e.code})");
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.redAccent,
        content: Text(
          message,
          style: const TextStyle(fontSize: 18.0, color: Colors.white),
        ),
      ));
    } catch (e) {
      if (!mounted) return;
      print("Generic Exception (Admin Login): $e");
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(
            "Ocorreu um erro desconhecido. Tente novamente.",
            style: TextStyle(fontSize: 18.0, color: Colors.white),
          )));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: screenHeight - MediaQuery.of(context).padding.top,
            ),
            child: Column(
              children: <Widget>[
                _buildHeader(screenHeight, screenWidth),
                _buildFormContainer(screenHeight, screenWidth),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(double screenHeight, double screenWidth) {
    double headerHeight = screenHeight / 2.8;
    double logoImageHeight = screenHeight * 0.10;
    double logoBackgroundDiameter = logoImageHeight * 1.4;

    return Container(
      padding: EdgeInsets.only(
        top: screenHeight * 0.04,
        left: screenWidth * 0.07,
        right: screenWidth * 0.07,
        bottom: screenHeight * 0.03,
      ),
      height: headerHeight,
      width: screenWidth,
      decoration: const BoxDecoration(
          gradient: LinearGradient(
              colors: [kPrimaryColor, kAccentColor, kGradientEndColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: logoBackgroundDiameter,
            height: logoBackgroundDiameter,
            padding: EdgeInsets.all(logoImageHeight * 0.1),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 5.0,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: Center(
              child: Image.asset(
                'images/ufrpe.png', // Caminho da logo
                height: logoImageHeight,
                fit: BoxFit.contain,
              ),
            ),
          ),
          SizedBox(height: screenHeight * 0.025),
          const Text(
            "Admin\nPainel", // Texto do Header
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.white,
                fontSize: 22.0,
                fontWeight: FontWeight.bold,
                height: 1.2,
                shadows: [
                  Shadow(
                      blurRadius: 6.0,
                      color: Colors.black26,
                      offset: Offset(2, 2))
                ]),
          ),
        ],
      ),
    );
  }

  Widget _buildFormContainer(double screenHeight, double screenWidth) {
    return Transform.translate(
      offset: Offset(0, -screenHeight * 0.06),
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.07, vertical: screenHeight * 0.04),
        width: screenWidth,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(40),
            topRight: Radius.circular(40),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              spreadRadius: 0,
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(height: screenHeight * 0.02),
              _buildTextFormField(
                controller: emailController,
                labelText: "E-mail Administrador",
                hintText: "admin@ufrpe.br",
                icon: Icons.admin_panel_settings_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, informe o E-mail';
                  }
                  final emailRegex = RegExp(
                      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
                  if (!emailRegex.hasMatch(value)) {
                    return 'Formato de e-mail inválido';
                  }
                  return null;
                },
              ),
              SizedBox(height: screenHeight * 0.025),
              _buildTextFormField(
                controller: passwordController,
                labelText: "Senha",
                hintText: "Digite sua senha",
                icon: Icons.lock_outline,
                obscureText: _obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: kAccentColor.withOpacity(0.7),
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, informe a Senha';
                  }
                  return null;
                },
              ),
              SizedBox(height: screenHeight * 0.04),
              _buildSubmitButton(),
              SizedBox(height: screenHeight * 0.04),
              _buildUserLoginLink(context),
              SizedBox(height: screenHeight * 0.02),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: const TextStyle(color: kPrimaryColor, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle:
            TextStyle(color: kAccentColor.withOpacity(0.8), fontSize: 16),
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        prefixIcon: Icon(icon, color: kAccentColor.withOpacity(0.7), size: 22),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: kAccentColor.withOpacity(0.03),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: kAccentColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      ),
      validator: validator,
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        padding: EdgeInsets.zero,
        elevation: _isLoading ? 0 : 8,
        shadowColor: kPrimaryColor.withOpacity(0.4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ).copyWith(
        backgroundColor: MaterialStateProperty.all(Colors.transparent),
      ),
      onPressed: _isLoading ? null : loginAdmin,
      child: Ink(
        decoration: BoxDecoration(
          gradient: _isLoading
              ? null
              : const LinearGradient(
                  colors: [kPrimaryColor, kAccentColor, kGradientEndColor]),
          color: _isLoading ? Colors.grey.shade400 : null,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          alignment: Alignment.center,
          child: _isLoading
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 2.5,
                  ),
                )
              : const Text(
                  "ENTRAR",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildUserLoginLink(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          "Não é administrador?",
          style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 16.0,
          ),
        ),
        TextButton(
          onPressed: _isLoading
              ? null
              : () {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => const LogIn()));
                },
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          ),
          child: const Text(
            "Login de Usuário",
            style: TextStyle(
                color: kAccentColor,
                fontSize: 16.0,
                fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
