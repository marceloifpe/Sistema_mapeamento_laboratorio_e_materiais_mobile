import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sistema_mapeamento_de_materiais/Admin/admin_login.dart';
import 'package:sistema_mapeamento_de_materiais/pages/login.dart';

void main() {
  testWidgets('Teste completo do AdminLogin', (WidgetTester tester) async {
    // Configurar o widget com tamanho de tela grande
    tester.binding.window.physicalSizeTestValue = const Size(1440, 2560);
    tester.binding.window.devicePixelRatioTestValue = 1.0;

    await tester.pumpWidget(
      MaterialApp(
        home: const AdminLogin(),
        routes: {
          '/login': (context) => const LogIn(),
        },
      ),
    );

    // Aguardar renderização
    await tester.pumpAndSettle();

    // 1. Verificar elementos principais
    expect(find.textContaining(RegExp(r'Admin\s*Painel')), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));

    // 2. Testar validação de campos vazios
    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();
    expect(find.text('Campo obrigatório'), findsNWidgets(2));

    // 3. Testar email inválido
    await tester.enterText(find.byType(TextFormField).at(0), 'emailinvalido');
    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();
    expect(find.text('Digite um e-mail válido'), findsOneWidget);

    // 4. Testar email não-admin
    await tester.enterText(find.byType(TextFormField).at(0), 'user@ufrpe.br');
    await tester.enterText(find.byType(TextFormField).at(1), 'senha123');
    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();
    expect(find.text('Apenas o email admin@ufrpe.br pode acessar!'),
        findsOneWidget);

    // 5. Testar navegação para login de professor
    final professorFinder = find.text('Login Professor');

    // Se não estiver visível, fazer scroll
    if (tester.getRect(professorFinder).bottom >
        tester.binding.window.physicalSize.height) {
      await tester.drag(
          find.byType(SingleChildScrollView), const Offset(0, -200));
      await tester.pumpAndSettle();
    }

    await tester.tap(professorFinder);
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.byType(LogIn), findsOneWidget);

    // Resetar o tamanho da janela
    addTearDown(() => tester.binding.window.clearPhysicalSizeTestValue());
  });
}
