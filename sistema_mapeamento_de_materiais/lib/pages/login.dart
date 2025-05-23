import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sistema_mapeamento_de_materiais/Admin/admin_login.dart'; // Seu import
import 'package:sistema_mapeamento_de_materiais/pages/home.dart'; // Seu import
import 'package:sistema_mapeamento_de_materiais/pages/signup.dart'; // Seu import
import 'package:sistema_mapeamento_de_materiais/services/shared_pref.dart'; // <<< IMPORT ADICIONADO
// Import para a tela de "Esqueci minha senha", se você tiver uma.
// import 'package:sistema_mapeamento_de_materiais/pages/forgot_password.dart';

class LogIn extends StatefulWidget {
  const LogIn({super.key});

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  String? mail, password; // Mantido, mas idealmente ler direto dos controllers
  final TextEditingController emailcontroller = TextEditingController();
  final TextEditingController passwordcontroller = TextEditingController();

  final _formkey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _obscurePassword = true;

  // Cores consistentes com SignUp
  static const Color kPrimaryColor = Color(0xFF091057);
  static const Color kAccentColor = Color(0xff1F509A);
  static const Color kGradientEndColor = Color(0xFF311937);

  @override
  void dispose() {
    emailcontroller.dispose();
    passwordcontroller.dispose();
    super.dispose();
  }

  Future<void> userLogin() async {
    // Atribuir valores dos controllers antes de usar
    // É mais seguro ler diretamente dos controllers no momento do uso
    final String currentEmail = emailcontroller.text.trim();
    final String currentPassword = passwordcontroller.text.trim();

    if (currentEmail.isEmpty || currentPassword.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Colors.orangeAccent,
          content: Text(
            "Por favor, preencha e-mail e senha.",
            style: TextStyle(fontSize: 18.0, color: Colors.white),
          ),
        ));
      }
      return; // Não prosseguir se os campos estiverem vazios
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // <<< MODIFICADO para obter UserCredential
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: currentEmail, password: currentPassword);

      // --- INÍCIO DA CORREÇÃO ---
      // Obter o ID do usuário logado
      String firebaseUserId = userCredential.user!.uid;

      // Salvar o ID do usuário no SharedPreferences
      await SharedpreferenceHelper().saveUserId(firebaseUserId);

      // Opcional: Salvar outros dados como email, se necessário
      // await SharedpreferenceHelper().saveUserEmail(currentEmail);
      // --- FIM DA CORREÇÃO ---

      if (!mounted) return;
      // Opcional: Mostrar SnackBar de sucesso
      // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      //   backgroundColor: Colors.green,
      //   content: Text(
      //     "Login realizado com sucesso!",
      //     style: TextStyle(fontSize: 18.0, color: Colors.white),
      //   ),
      // ));
      Navigator.pushReplacement(
          // Usar pushReplacement para não voltar à tela de login
          context,
          MaterialPageRoute(builder: (context) => const Home()));
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      String message;
      // <<< Códigos de erro atualizados para Firebase mais recente
      if (e.code == 'user-not-found' ||
          e.code == 'wrong-password' ||
          e.code == 'invalid-credential') {
        message = "E-mail ou senha inválidos!";
      } else if (e.code == 'invalid-email') {
        message = "O formato do e-mail é inválido.";
      } else if (e.code == 'too-many-requests') {
        message = "Muitas tentativas de login. Tente novamente mais tarde.";
      } else {
        message = "Erro ao realizar login. Tente novamente.";
        print("Firebase Auth Exception (Login): ${e.message} (${e.code})");
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
      print("Generic Exception (Login): $e");
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
                'images/ufrpe.png', // Certifique-se que este caminho está correto
                height: logoImageHeight,
                fit: BoxFit.contain,
              ),
            ),
          ),
          SizedBox(height: screenHeight * 0.025),
          const Text(
            "Olá\nLogin!",
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
          key: _formkey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(height: screenHeight * 0.02),
              _buildTextFormField(
                controller: emailcontroller,
                labelText: "E-mail Institucional",
                hintText: "seuemail@ufrpe.br",
                icon: Icons.mail_outline,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, informe o E-mail';
                  }
                  // Adapte esta lógica se necessário para diferenciar admin de usuário comum.
                  // Se o admin_login é separado, esta validação pode ser mais restrita.
                  // if (!value.endsWith('@ufrpe.br')) {
                  //   return 'E-mail deve ser do domínio @ufrpe.br';
                  // }
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
                controller: passwordcontroller,
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
              SizedBox(height: screenHeight * 0.015),
              _buildForgotPasswordLink(context), // Link de "Esqueceu a senha?"
              SizedBox(height: screenHeight * 0.03),
              _buildSubmitButton(),
              SizedBox(height: screenHeight * 0.03),
              _buildSignUpLink(context),
              SizedBox(height: screenHeight * 0.015),
              _buildAdminLoginLink(context),
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

  Widget _buildForgotPasswordLink(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: _isLoading
            ? null
            : () {
                // TODO: Implementar navegação para tela de "Esqueci minha senha"
                // Exemplo: Navigator.push(context, MaterialPageRoute(builder: (context) => ForgotPasswordScreen()));
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          "Funcionalidade 'Esqueci a Senha' não implementada."),
                      backgroundColor: Colors.amber,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
        ),
        child: Text(
          "Esqueceu a Senha?",
          style: TextStyle(
            color: kAccentColor.withOpacity(0.9),
            fontSize: 15.0,
          ),
        ),
      ),
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
      onPressed: _isLoading
          ? null
          : () {
              if (_formkey.currentState!.validate()) {
                userLogin();
              }
            },
      child: Ink(
        decoration: BoxDecoration(
          gradient: _isLoading
              ? null // Sem gradiente durante o loading
              : const LinearGradient(
                  colors: [kPrimaryColor, kAccentColor],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
          color: _isLoading
              ? Colors.grey.shade400
              : null, // Cor cinza durante o loading
          borderRadius: BorderRadius.circular(30),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          alignment: Alignment.center,
          child: _isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : const Text(
                  'LOGIN',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17.0,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildSignUpLink(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const Text(
          "Não tem uma conta? ",
          style: TextStyle(color: Colors.black54, fontSize: 16.0),
        ),
        GestureDetector(
          onTap: _isLoading
              ? null
              : () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              const SignUp())); // Navega para SignUp
                },
          child: Text(
            "Cadastre-se",
            style: TextStyle(
              color: kAccentColor,
              fontSize: 16.5,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
              decorationColor: kAccentColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAdminLoginLink(BuildContext context) {
    return TextButton(
      onPressed: _isLoading
          ? null
          : () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          const AdminLogin())); // Navega para AdminLogin
            },
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        // foregroundColor: kPrimaryColor.withOpacity(0.8),
      ),
      child: Text(
        "Entrar como Administrador",
        style: TextStyle(
          color: kPrimaryColor.withOpacity(0.9),
          fontSize: 15.5,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
