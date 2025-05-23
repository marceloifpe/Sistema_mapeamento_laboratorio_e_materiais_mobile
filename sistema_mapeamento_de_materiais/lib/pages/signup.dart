import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:random_string/random_string.dart'; // Embora não usado após a mudança para firebaseUserId, pode ser mantido se houver outros usos.
import 'package:sistema_mapeamento_de_materiais/pages/home.dart';
import 'package:sistema_mapeamento_de_materiais/pages/login.dart';
import 'package:sistema_mapeamento_de_materiais/services/database.dart';
import 'package:sistema_mapeamento_de_materiais/services/shared_pref.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  String? name, mail, password;
  final TextEditingController namecontroller = TextEditingController();
  final TextEditingController emailcontroller = TextEditingController();
  final TextEditingController passwordcontroller = TextEditingController();

  final _formkey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _obscurePassword = true;

  static const Color kPrimaryColor = Color(0xFF091057);
  static const Color kAccentColor = Color(0xff1F509A);
  static const Color kGradientEndColor = Color(0xFF311937);

  @override
  void dispose() {
    namecontroller.dispose();
    emailcontroller.dispose();
    passwordcontroller.dispose();
    super.dispose();
  }

  bool isStrongPassword(String password) {
    final regex = RegExp(
        r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$');
    return regex.hasMatch(password);
  }

  Future<void> registration() async {
    // É mais seguro ler dos controllers no momento do uso ou garantir que name, mail, password
    // sejam atualizados via onChanged ANTES de chamar esta função.
    // Para este exemplo, vamos assumir que foram atualizados pelo onChanged no _buildTextFormField.
    // Se não, você deveria ler dos controllers aqui:
    // name = namecontroller.text.trim();
    // mail = emailcontroller.text.trim();
    // password = passwordcontroller.text.trim();

    if (passwordcontroller.text.isNotEmpty &&
        namecontroller.text.isNotEmpty &&
        emailcontroller.text.isNotEmpty) {
      // Validar com os controllers
      setState(() {
        _isLoading = true;
      });
      try {
        // Usar os valores dos controllers diretamente para garantir que são os mais recentes
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
                email: emailcontroller.text.trim(),
                password: passwordcontroller.text.trim());
        String firebaseUserId = userCredential.user!.uid;

        await SharedpreferenceHelper().saveUserName(namecontroller.text.trim());
        await SharedpreferenceHelper()
            .saveUserEmail(emailcontroller.text.trim());
        await SharedpreferenceHelper().saveUserId(firebaseUserId);

        Map<String, dynamic> userInfoMap = {
          "Nome": namecontroller.text.trim(),
          "Email": emailcontroller.text.trim(),
          "Id": firebaseUserId,
        };
        await DatabaseMethods().addUserDetails(userInfoMap, firebaseUserId);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            backgroundColor: Colors.green,
            content: Text(
              "Registrado com Sucesso!",
              style: TextStyle(fontSize: 18.0, color: Colors.white),
            )));
        Navigator.pushReplacement(
            // Usar pushReplacement
            context,
            MaterialPageRoute(builder: (context) => const Home()));
      } on FirebaseAuthException catch (e) {
        if (!mounted) return;
        String message;
        if (e.code == 'weak-password') {
          message = "A senha fornecida é muito fraca!";
        } else if (e.code == "email-already-in-use") {
          message = "Este e-mail já está em uso!";
        } else if (e.code == "invalid-email") {
          message = "O formato do e-mail é inválido.";
        } else {
          message = "Ocorreu um erro no registro. Tente novamente.";
          print("Firebase Auth Exception: ${e.message} (${e.code})");
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text(
              message,
              style: const TextStyle(fontSize: 18.0, color: Colors.white),
            )));
      } catch (e) {
        if (!mounted) return;
        print("Generic Exception: $e");
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
    } else {
      // Este else pode não ser necessário se a validação do _formKey.currentState!.validate() for feita antes.
      // Ou se a validação inicial dos campos do controller for suficiente.
      // No entanto, manter uma verificação de segurança não é ruim.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            backgroundColor: Colors.orangeAccent,
            content: Text(
              "Por favor, preencha todos os campos corretamente.",
              style: TextStyle(fontSize: 18.0, color: Colors.white),
            )));
        // Garante que o loading pare se essa condição for atingida.
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
                'images/ufrpe.png',
                height: logoImageHeight,
                fit: BoxFit.contain,
              ),
            ),
          ),
          SizedBox(height: screenHeight * 0.025),
          const Text(
            "Crie sua\nConta!",
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.white,
                fontSize:
                    22.0, // Ajustado o tamanho da fonte no SignUp original
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
                controller: namecontroller,
                labelText: "Nome Completo", // Mantido como "Nome Completo"
                hintText: "Digite seu nome", // Hint ajustado
                icon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, informe o Nome';
                  }
                  // A validação de nome e sobrenome foi removida daqui
                  return null;
                },
                onChanged: (value) =>
                    name = value.trim(), // Atualiza a variável de estado
              ),
              SizedBox(height: screenHeight * 0.025),
              _buildTextFormField(
                controller: emailcontroller,
                labelText: "E-mail Institucional",
                hintText: "exemplo@ufrpe.br",
                icon: Icons.mail_outline,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, informe o E-mail';
                  }
                  if (!value.endsWith('@ufrpe.br')) {
                    return 'E-mail deve ser do domínio @ufrpe.br';
                  }
                  final emailRegex = RegExp(
                      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
                  if (!emailRegex.hasMatch(value)) {
                    return 'Formato de e-mail inválido';
                  }
                  return null;
                },
                onChanged: (value) =>
                    mail = value.trim(), // Atualiza a variável de estado
              ),
              SizedBox(height: screenHeight * 0.025),
              _buildTextFormField(
                controller: passwordcontroller,
                labelText: "Senha",
                hintText: "Crie uma senha forte",
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
                    return 'Campo obrigatório';
                  }
                  if (!isStrongPassword(value)) {
                    return 'Mín. 8 caracteres, com maiúscula, minúscula, número e símbolo (@\$!%*?&).';
                  }
                  return null;
                },
                onChanged: (value) =>
                    password = value, // Atualiza a variável de estado
              ),
              SizedBox(height: screenHeight * 0.04),
              _buildSubmitButton(),
              SizedBox(height: screenHeight * 0.03),
              _buildLoginLink(context),
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
    ValueChanged<String>? onChanged, // Adicionado onChanged
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
      onChanged: onChanged, // Usando o parâmetro onChanged
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
                // Os onChanged nos TextFormFields já devem ter atualizado as variáveis name, mail, password.
                // Ou, alternativamente, você pode ler dos controllers aqui antes de chamar registration():
                // setState(() {
                //   name = namecontroller.text.trim();
                //   mail = emailcontroller.text.trim();
                //   password = passwordcontroller.text.trim();
                // });
                registration();
              }
            },
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
                  "CRIAR CONTA",
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

  Widget _buildLoginLink(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          "Já tem uma conta?",
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
            "Faça Login",
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
