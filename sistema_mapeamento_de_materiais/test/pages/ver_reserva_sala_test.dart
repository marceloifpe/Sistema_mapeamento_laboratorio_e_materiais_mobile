import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sistema_mapeamento_de_materiais/pages/ver_reserva_sala.dart';

void main() {
  group('Testes de Widget VerReservaSala', () {
    // Teste básico para a estrutura estática do widget VerReservaSala
    // Foca em elementos que não dependem do estado interno ou Firebase.
    testWidgets('VerReservaSala constrói AppBar e Scaffold corretamente',
        (WidgetTester tester) async {
      // Constrói o widget VerReservaSala dentro de um MaterialApp.
      await tester.pumpWidget(MaterialApp(home: VerReservaSala()));

      // Verifica se o Scaffold (estrutura básica da tela) está presente
      expect(find.byType(Scaffold), findsOneWidget);

      // Verifica se o título da AppBar está presente
      expect(find.text('Minhas Reservas de Sala'), findsOneWidget);
    });
  });
}
