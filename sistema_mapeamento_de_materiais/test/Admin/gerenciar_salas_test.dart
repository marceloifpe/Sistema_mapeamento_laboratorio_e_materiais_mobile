// /home/ubuntu/upload/gerenciar_salas_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Importa a classe GerenciarSalasPage apenas para referência de cores/constantes, se necessário,
// mas NÃO a usaremos diretamente nos testes para evitar a dependência do Firebase.
// import 'package:sistema_mapeamento_de_materiais/pages/gerenciar_salas.dart';

// --- CÓPIA MINIMALISTA DA UI DE GerenciarSalasPage (SEM FIREBASE) ---
// Criamos uma versão "fake" da tela, replicando a estrutura visual
// mas removendo todas as dependências do FirebaseFirestore e StreamBuilder.

class FakeGerenciarSalasPage extends StatefulWidget {
  const FakeGerenciarSalasPage({super.key});

  @override
  _FakeGerenciarSalasPageState createState() => _FakeGerenciarSalasPageState();
}

class _FakeGerenciarSalasPageState extends State<FakeGerenciarSalasPage> {
  // Constantes de cor (copiadas da classe original para manter a aparência)
  static const Color kPrimaryColor = Color(0xFF091057);
  static const Color kAccentColor = Color(0xff1F509A);
  static const Color kLightTextColor = Colors.white;
  static const Color kDarkTextColor = Colors.black87;
  static const Color kScaffoldBackgroundColor = Color(0xFFF4F6F8);
  static const Color kCardBackgroundColor = Colors.white;
  static const Color kErrorColor = Colors.redAccent;

  final List<String> _locaisDisponiveis = ["UABJ", "AEB"];

  // Lógica do diálogo (mantida, mas sem chamadas ao Firestore)
  void _adicionarOuEditarSala({String? id, String? nome, String? local}) {
    String novoNome = nome ?? "";
    String novoLocal = (local != null && _locaisDisponiveis.contains(local))
        ? local
        : _locaisDisponiveis.first;

    TextEditingController nomeController = TextEditingController(text: nome);
    String? localSelecionadoNoDialog = novoLocal;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          title: Text(
            id == null ? "Adicionar Nova Sala" : "Editar Sala",
            style: const TextStyle(
                color: kPrimaryColor, fontWeight: FontWeight.bold),
          ),
          content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setStateDialog) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nomeController,
                  decoration: InputDecoration(
                    labelText: "Nome da Sala",
                    labelStyle: const TextStyle(color: kAccentColor),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: kPrimaryColor, width: 2.0),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    prefixIcon: const Icon(Icons.meeting_room_outlined,
                        color: kAccentColor),
                  ),
                  style: const TextStyle(color: kDarkTextColor),
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: localSelecionadoNoDialog,
                  decoration: InputDecoration(
                    labelText: "Local da Sala",
                    labelStyle: const TextStyle(color: kAccentColor),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: kPrimaryColor, width: 2.0),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    prefixIcon: const Icon(Icons.location_on_outlined,
                        color: kAccentColor),
                  ),
                  items: _locaisDisponiveis.map((String localItem) {
                    return DropdownMenuItem(
                        value: localItem, child: Text(localItem));
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setStateDialog(() {
                        localSelecionadoNoDialog = value;
                      });
                      novoLocal = value;
                    }
                  },
                  style: const TextStyle(color: kDarkTextColor, fontSize: 16),
                  dropdownColor: kCardBackgroundColor,
                ),
              ],
            );
          }),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child:
                  const Text("Cancelar", style: TextStyle(color: kAccentColor)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)),
              ),
              onPressed: () async {
                // Ação de salvar removida (sem Firestore)
                novoNome = nomeController.text.trim();
                if (novoNome.isNotEmpty) {
                  // Apenas fecha o diálogo no teste
                  print(
                      "Fake Add/Edit Sala: Nome=$novoNome, Local=$novoLocal, ID=$id");
                }
                if (mounted) Navigator.pop(context);
              },
              child: Text(id == null ? "Adicionar" : "Salvar Alterações",
                  style: const TextStyle(color: kLightTextColor)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kScaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "Gerenciar Salas",
          style: TextStyle(color: kLightTextColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: kPrimaryColor,
        iconTheme: const IconThemeData(color: kLightTextColor),
        elevation: 1.0,
      ),
      // Corpo da tela substituído por uma mensagem fixa, pois não há StreamBuilder
      body: const Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.meeting_room_outlined, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            "Nenhuma sala cadastrada ainda (Fake View).",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18.0, color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text(
            "Clique no botão '+' para adicionar.",
            style: TextStyle(fontSize: 16.0, color: Colors.grey),
          ),
        ],
      )),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: kPrimaryColor,
        icon: const Icon(Icons.add, color: kLightTextColor),
        label: const Text("Nova Sala",
            style:
                TextStyle(color: kLightTextColor, fontWeight: FontWeight.w600)),
        onPressed: () => _adicionarOuEditarSala(), // Chama a função do diálogo
        tooltip: 'Adicionar Nova Sala',
      ),
    );
  }
}

// --- FIM DA CÓPIA MINIMALISTA ---

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Testes Básicos da Interface Fake de Gerenciar Salas', () {
    // Função auxiliar agora constrói a FakeGerenciarSalasPage
    Future<void> pumpFakeGerenciarSalasPage(WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: FakeGerenciarSalasPage(), // Usa a versão Fake
      ));
    }

    // Teste 1: Verifica a presença do título na AppBar.
    testWidgets('Deve exibir o título "Gerenciar Salas" na AppBar',
        (WidgetTester tester) async {
      await pumpFakeGerenciarSalasPage(tester);
      final appBarFinder = find.byType(AppBar);
      expect(appBarFinder, findsOneWidget, reason: 'AppBar não encontrada');
      final titleFinder = find.descendant(
        of: appBarFinder,
        matching: find.text('Gerenciar Salas'),
      );
      expect(titleFinder, findsOneWidget,
          reason: 'Título "Gerenciar Salas" não encontrado na AppBar');
    });

    // Teste 2: Verifica a presença do FloatingActionButton.
    testWidgets('Deve exibir o FloatingActionButton "Nova Sala"',
        (WidgetTester tester) async {
      await pumpFakeGerenciarSalasPage(tester);
      final fabFinder = find.byType(FloatingActionButton);
      expect(fabFinder, findsOneWidget,
          reason: 'FloatingActionButton não encontrado');
      final fabTextFinder = find.descendant(
        of: fabFinder,
        matching: find.text('Nova Sala'),
      );
      expect(fabTextFinder, findsOneWidget,
          reason: 'Texto "Nova Sala" não encontrado no FAB');
      final fabIconFinder = find.descendant(
        of: fabFinder,
        matching: find.byIcon(Icons.add),
      );
      expect(fabIconFinder, findsOneWidget,
          reason: 'Ícone de adição não encontrado no FAB');
    });

    // Teste 3: Verifica se o diálogo de adicionar sala abre ao tocar no FAB.
    testWidgets('Deve abrir o diálogo "Adicionar Nova Sala" ao tocar no FAB',
        (WidgetTester tester) async {
      await pumpFakeGerenciarSalasPage(tester);
      final fabFinder = find.byType(FloatingActionButton);
      expect(fabFinder, findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);
      await tester.tap(fabFinder);
      await tester.pumpAndSettle(); // Aguarda o diálogo aparecer
      final dialogFinder = find.byType(AlertDialog);
      expect(dialogFinder, findsOneWidget,
          reason: 'Diálogo não abriu após tocar no FAB');
      final dialogTitleFinder = find.descendant(
        of: dialogFinder,
        matching: find.text('Adicionar Nova Sala'),
      );
      expect(dialogTitleFinder, findsOneWidget,
          reason: 'Título "Adicionar Nova Sala" não encontrado no diálogo');
    });

    // Teste 4: Verifica a presença dos elementos dentro do diálogo "Adicionar Nova Sala".
    testWidgets(
        'Deve exibir os campos e botões dentro do diálogo "Adicionar Nova Sala"',
        (WidgetTester tester) async {
      await pumpFakeGerenciarSalasPage(tester);
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      final dialogFinder = find.byType(AlertDialog);
      expect(dialogFinder, findsOneWidget);

      // Verifica campo Nome
      final nomeFieldFinder = find.descendant(
          of: dialogFinder,
          matching: find.widgetWithText(TextField, 'Nome da Sala'));
      expect(nomeFieldFinder, findsOneWidget,
          reason: 'Campo "Nome da Sala" não encontrado no diálogo');

      // Verifica dropdown Local
      final localDropdownFinder = find.descendant(
          of: dialogFinder,
          matching: find.widgetWithText(
              DropdownButtonFormField<String>, 'Local da Sala'));
      expect(localDropdownFinder, findsOneWidget,
          reason: 'Dropdown "Local da Sala" não encontrado no diálogo');

      // Verifica botão Cancelar
      final cancelButtonFinder = find.descendant(
          of: dialogFinder,
          matching: find.widgetWithText(TextButton, 'Cancelar'));
      expect(cancelButtonFinder, findsOneWidget,
          reason: 'Botão "Cancelar" não encontrado no diálogo');

      // Verifica botão Adicionar
      final addButtonFinder = find.descendant(
          of: dialogFinder,
          matching: find.widgetWithText(ElevatedButton, 'Adicionar'));
      expect(addButtonFinder, findsOneWidget,
          reason: 'Botão "Adicionar" não encontrado no diálogo');
    });

    // Teste 5: Verifica a presença da mensagem de estado vazio (na versão Fake).
    testWidgets('Deve exibir a mensagem de estado vazio da Fake View',
        (WidgetTester tester) async {
      await pumpFakeGerenciarSalasPage(tester);

      // Verifica a presença do ícone e dos textos específicos da Fake View
      expect(find.byIcon(Icons.meeting_room_outlined), findsOneWidget);
      expect(find.text('Nenhuma sala cadastrada ainda (Fake View).'),
          findsOneWidget);
      expect(
          find.text('Clique no botão \'+\' para adicionar.'), findsOneWidget);

      // Garante que não há CircularProgressIndicator (pois não há carregamento na Fake View)
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });
}
