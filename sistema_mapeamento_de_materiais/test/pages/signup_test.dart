import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sistema_mapeamento_de_materiais/pages/signup.dart';
import 'package:sistema_mapeamento_de_materiais/pages/login.dart';

void main() {
  testWidgets('Teste completo da tela de SignUp', (WidgetTester tester) async {
    // Configurar tamanho de tela grande para evitar overflow
    tester.binding.window.physicalSizeTestValue = const Size(1440, 2560);
    tester.binding.window.devicePixelRatioTestValue = 1.0;

    await tester.pumpWidget(
      MaterialApp(
        home: const SignUp(),
        routes: {
          '/login': (context) => const LogIn(),
        },
      ),
    );

    // Aguardar renderização completa
    await tester.pumpAndSettle();

    // 1. Verificar elementos principais
    expect(find.textContaining(RegExp(r'Crie sua\s*Conta!')), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(3));

    // 2. Encontrar o botão de submit
    final submitButton = find.text('CRIE SUA CONTA');
    await tester.ensureVisible(submitButton);

    // 3. Testar validação de campos vazios
    await tester.tap(submitButton);
    await tester.pumpAndSettle();

    // Verificar mensagens de erro com rolagem se necessário
    final errorFinders = [
      find.text('Por favor informe o Nome'),
      find.text('Por favor informe o E-mail'),
      find.text('Campo obrigatório')
    ];

    for (final finder in errorFinders) {
      await tester.ensureVisible(finder);
      expect(finder, findsOneWidget);
    }

    // 4. Preencher formulário corretamente
    final formFields = find.byType(TextFormField);
    await tester.enterText(formFields.at(0), 'Nome Teste');
    await tester.enterText(formFields.at(1), 'teste@ufrpe.br');
    await tester.enterText(formFields.at(2), 'SenhaForte123@');

    // 5. Testar navegação para Login
    final loginButton = find.text('Vá para o Login');
    await tester.ensureVisible(loginButton);
    await tester.tap(loginButton);
    await tester.pumpAndSettle();

    expect(find.byType(LogIn), findsOneWidget);

    // Resetar tamanho da janela
    addTearDown(() => tester.binding.window.clearPhysicalSizeTestValue());
  });
}
