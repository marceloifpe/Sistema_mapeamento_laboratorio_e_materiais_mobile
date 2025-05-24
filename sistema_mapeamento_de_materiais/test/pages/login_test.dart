// /home/ubuntu/upload/login_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Importa a classe LogIn que será testada.
// Certifique-se de que o caminho de importação está correto para a estrutura do seu projeto.
import 'package:sistema_mapeamento_de_materiais/pages/login.dart';

// Importa as outras páginas para onde a navegação pode ocorrer,
// apenas para garantir que os links existam, sem testar a navegação em si.
import 'package:sistema_mapeamento_de_materiais/pages/signup.dart';
import 'package:sistema_mapeamento_de_materiais/Admin/admin_login.dart';

void main() {
  // Garante que os bindings do Flutter sejam inicializados antes dos testes de widget.
  TestWidgetsFlutterBinding.ensureInitialized();

  // Grupo de testes para a tela de Login, focando em funcionalidades básicas da UI.
  group('Testes Básicos da Interface de Login (sem Mocks/Firebase)', () {
    // Função auxiliar para construir o widget LogIn dentro de um MaterialApp.
    Future<void> pumpLoginWidget(WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: const LogIn(),
        routes: {
          '/signup': (context) => const SignUp(), // Rota para cadastro
          '/admin_login': (context) =>
              const AdminLogin(), // Rota para login admin
        },
      ));
    }

    // Teste 1: Verifica se os campos de e-mail e senha estão presentes na tela.
    testWidgets('Deve exibir os campos de E-mail e Senha',
        (WidgetTester tester) async {
      await pumpLoginWidget(tester);
      final emailFieldFinder =
          find.widgetWithText(TextFormField, 'E-mail Institucional');
      final passwordFieldFinder = find.widgetWithText(TextFormField, 'Senha');
      expect(emailFieldFinder, findsOneWidget,
          reason: 'Campo de E-mail não encontrado');
      expect(passwordFieldFinder, findsOneWidget,
          reason: 'Campo de Senha não encontrado');
    });

    // Teste 2: Verifica se o botão principal de login está presente.
    testWidgets('Deve exibir o botão de Login', (WidgetTester tester) async {
      await pumpLoginWidget(tester);
      final loginButtonFinder = find.byType(ElevatedButton);
      expect(loginButtonFinder, findsOneWidget,
          reason: 'Botão de Login não encontrado');
    });

    // Teste 3: Verifica a validação local quando os campos estão vazios.
    testWidgets(
        'Deve exibir mensagem de erro ao tentar logar com campos vazios',
        (WidgetTester tester) async {
      await pumpLoginWidget(tester);
      final loginButtonFinder = find.byType(ElevatedButton);
      expect(loginButtonFinder, findsOneWidget);
      await tester.tap(loginButtonFinder);
      await tester.pump();
      expect(find.text('Por favor, informe o E-mail'), findsOneWidget,
          reason: 'Mensagem de erro para e-mail vazio não encontrada');
      expect(find.text('Por favor, informe a Senha'), findsOneWidget,
          reason: 'Mensagem de erro para senha vazia não encontrada');
    });

    // Teste 4: Verifica a funcionalidade do botão de mostrar/ocultar senha.
    testWidgets('Deve alternar a visibilidade da senha ao clicar no ícone',
        (WidgetTester tester) async {
      await pumpLoginWidget(tester);
      final passwordFieldFinder = find.widgetWithText(TextFormField, 'Senha');
      expect(passwordFieldFinder, findsOneWidget);

      bool isPasswordObscured() {
        final editableTextFinder = find.descendant(
          of: passwordFieldFinder,
          matching: find.byType(EditableText),
        );
        expect(editableTextFinder, findsOneWidget);
        final EditableText editableText = tester.widget(editableTextFinder);
        return editableText.obscureText;
      }

      // 1. Verifica estado inicial
      expect(isPasswordObscured(), isTrue,
          reason: 'Senha não está oculta inicialmente');
      final initialIconFinder = find.descendant(
        of: passwordFieldFinder,
        matching: find.byIcon(Icons.visibility_off_outlined),
      );
      expect(initialIconFinder, findsOneWidget,
          reason: 'Ícone de visibilidade desligada não encontrado');

      // 2. Toca no ícone
      await tester.tap(initialIconFinder);
      await tester.pump();

      // 3. Verifica estado após primeiro toque
      expect(isPasswordObscured(), isFalse,
          reason: 'Senha não ficou visível após o clique');
      final visibleIconFinder = find.descendant(
        of: passwordFieldFinder,
        matching: find.byIcon(Icons.visibility_outlined),
      );
      expect(visibleIconFinder, findsOneWidget,
          reason: 'Ícone de visibilidade ligada não encontrado');
      expect(
          find.descendant(
              of: passwordFieldFinder,
              matching: find.byIcon(Icons.visibility_off_outlined)),
          findsNothing);

      // 4. Toca novamente no ícone
      await tester.tap(visibleIconFinder);
      await tester.pump();

      // 5. Verifica estado final
      expect(isPasswordObscured(), isTrue,
          reason: 'Senha não voltou a ficar oculta');
      expect(
          find.descendant(
              of: passwordFieldFinder,
              matching: find.byIcon(Icons.visibility_off_outlined)),
          findsOneWidget,
          reason:
              'Ícone de visibilidade desligada não encontrado após segundo clique');
      expect(
          find.descendant(
              of: passwordFieldFinder,
              matching: find.byIcon(Icons.visibility_outlined)),
          findsNothing);
    });

    // Teste 5: Verifica a presença dos links de navegação secundária
    testWidgets(
      'Deve exibir os textos dos links "Esqueceu a Senha?" e "Cadastre-se"',
      (WidgetTester tester) async {
        await pumpLoginWidget(tester);

        // Procura pelos widgets que exibem os textos específicos dos links,
        // independentemente do tipo de widget (TextButton, InkWell, etc.).
        final forgotPasswordTextFinder = find.text('Esqueceu a Senha?');
        final signUpTextFinder = find.text('Cadastre-se');

        // Verifica se todos os textos dos links foram encontrados na tela.
        expect(forgotPasswordTextFinder, findsOneWidget,
            reason: 'Texto "Esqueceu a Senha?" não encontrado');
        expect(signUpTextFinder, findsOneWidget,
            reason: 'Texto "Cadastre-se" não encontrado');
        // Nota: Este teste apenas verifica a presença visual dos textos dos links.
      },
    );
  });
}
