import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Para formatação de data
import 'package:sistema_mapeamento_de_materiais/services/shared_pref.dart';
import 'QRScannerScreen.dart'; // Seu import da tela de scanner

class ReservaMaterial extends StatefulWidget {
  final String service; // Ex: "Material por QRCode"

  ReservaMaterial({required this.service, super.key}); // super.key adicionado

  @override
  State<ReservaMaterial> createState() => _ReservaMaterialState();
}

class _ReservaMaterialState extends State<ReservaMaterial> {
  String? name, email, userId;
  String? selectedMaterialName;
  String?
      selectedMaterialId; // Armazena o ID do documento do material do Firestore

  // Datas como no seu original
  DateTime _requestDate = DateTime.now();
  DateTime _returnDate =
      DateTime.now().add(const Duration(days: 1)); // Padrão de devolução
  DateTime _reservationDate =
      DateTime.now().add(const Duration(hours: 1)); // Padrão de reserva

  bool _isLoadingSave = false; // Para o botão de salvar
  bool _isProcessingScan =
      false; // Para feedback durante a busca do material pós-scan

  // Cores consistentes
  static const Color kPrimaryColor = Color(0xFF091057);
  static const Color kAccentColor = Color(0xff1F509A);
  static const Color kLightTextColor = Colors.white;
  static const Color kDarkTextColor = Colors.black87;
  static const Color kScaffoldBackgroundColor = Color(0xFFF4F6F8);
  static const Color kCardBackgroundColor = Colors.white;
  static const Color kDisabledColor =
      Colors.grey; // Mesma definição das outras telas

  final DateFormat _dateTimeFormatter = DateFormat('dd/MM/yyyy HH:mm');

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  Future<void> getUserData() async {
    name = await SharedpreferenceHelper().getUserName();
    email = await SharedpreferenceHelper().getUserEmail();
    userId = await SharedpreferenceHelper().getUserId();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> fetchMaterialById(String scannedQrCodeValue) async {
    if (mounted) setState(() => _isProcessingScan = true);
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("materiais")
          .where("qr_code", isEqualTo: scannedQrCodeValue)
          .limit(1)
          .get();

      if (mounted) {
        // Verificar `mounted` antes de `setState`
        if (querySnapshot.docs.isNotEmpty) {
          var materialData = querySnapshot.docs.first;
          setState(() {
            selectedMaterialId = materialData.id; // ID do documento Firestore
            selectedMaterialName =
                materialData['nome_do_material'] as String? ??
                    'Nome Desconhecido';
            _isProcessingScan = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                backgroundColor: Colors.green,
                content: Text("Material encontrado: $selectedMaterialName",
                    style: const TextStyle(color: kLightTextColor))),
          );
        } else {
          setState(() {
            selectedMaterialId = null;
            selectedMaterialName = 'Material não encontrado';
            _isProcessingScan = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                backgroundColor: Colors.orangeAccent,
                content: Text("Material não encontrado. Verifique o QR Code.",
                    style: TextStyle(color: kLightTextColor))),
          );
        }
      }
    } catch (e) {
      print("Erro ao buscar material: $e");
      if (mounted) {
        setState(() {
          selectedMaterialId = null; // Limpar em caso de erro também
          selectedMaterialName = 'Erro na busca';
          _isProcessingScan = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              backgroundColor: Colors.redAccent,
              content: Text("Erro ao buscar material. Tente novamente.",
                  style: const TextStyle(color: kLightTextColor))),
        );
      }
    }
  }

  // Lógica original de scanQRCode mantida
  Future<void> scanQRCode() async {
    // A variável scannedMaterialId aqui armazena temporariamente o valor do QR Code (string)
    final scannedMaterialId = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => QRScannerScreen(
          onScan: (result) {
            // result é o valor string do QR Code
            // A sua lógica original chama fetchMaterialById aqui.
            // selectedMaterialId (variável de estado) será atualizada dentro de fetchMaterialById
            // para o ID do Documento do Firestore.
            if (result.isNotEmpty) {
              // Removido ?. pois result é String, não String?
              // setState(() {
              //   // selectedMaterialId = result; // Temporariamente o QR Code string
              // }); // Esta linha é redundante se fetchMaterialById faz o setState necessário
              fetchMaterialById(result);
            }
          },
        ),
      ),
    );

    // Esta parte da sua lógica original é provavelmente redundante se onScan já trata tudo,
    // pois QRScannerScreen não retorna valor explicitamente no Navigator.pop.
    // Mas, para "não alterar nada na lógica", ela é mantida.
    if (scannedMaterialId?.isNotEmpty ?? false) {
      // setState(() {
      //   selectedMaterialId = scannedMaterialId; // Novamente, selectedMaterialId (estado) seria o QR string
      // });
      fetchMaterialById(scannedMaterialId!);
    }
  }

  Future<void> saveReservation() async {
    if (selectedMaterialName != null && selectedMaterialId != null) {
      // Validação de datas
      if (_reservationDate.isBefore(_requestDate) ||
          _returnDate.isBefore(_reservationDate)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              backgroundColor: Colors.orangeAccent,
              content: Text("Datas inválidas. Verifique a ordem e os horários.",
                  style: TextStyle(color: kLightTextColor))),
        );
        return;
      }

      if (mounted) setState(() => _isLoadingSave = true);
      try {
        // Estrutura de salvamento EXATAMENTE como no seu original
        await FirebaseFirestore.instance.collection("reserva").add({
          'usuarios_id': userId,
          'material_id': selectedMaterialId, // ID do documento do Firestore
          'material_nome': selectedMaterialName,
          'data_solicitacao': _requestDate,
          'data_reserva': _reservationDate,
          'data_devolucao': _returnDate,
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                backgroundColor: Colors.green,
                content: Text("Reserva realizada com sucesso!",
                    style: TextStyle(color: kLightTextColor))),
          );
          Navigator.pop(context); // Voltar após sucesso
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                backgroundColor: Colors.redAccent,
                content: Text("Erro ao realizar a reserva: $e",
                    style: const TextStyle(color: kLightTextColor))),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoadingSave = false);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            backgroundColor: Colors.orangeAccent, // Cor para alerta
            content: Text("Escanear QR Code e definir datas antes de salvar!",
                style: TextStyle(color: kLightTextColor))),
      );
    }
  }

  Future<void> _selectDateAndTime(BuildContext context, int dateType) async {
    DateTime initialDate;
    // Correção na lógica de dateType para corresponder ao uso
    // dateType == 1 -> _requestDate (não usado via UI pois é read-only)
    // dateType == 2 -> _returnDate
    // dateType == 3 -> _reservationDate
    // A data de solicitação é DateTime.now() e não é alterada pelo picker.

    DateTime firstAllowedDate =
        DateTime.now().subtract(const Duration(days: 1));

    switch (dateType) {
      case 3: // Data de Reserva (_reservationDate)
        initialDate = _reservationDate;
        firstAllowedDate =
            _requestDate; // Reserva não pode ser antes da solicitação
        break;
      case 2: // Data de Devolução (_returnDate)
        initialDate = _returnDate;
        firstAllowedDate =
            _reservationDate; // Devolução não pode ser antes da reserva
        break;
      // case 1 para _requestDate não é chamado pela UI, pois é read-only.
      default:
        initialDate = DateTime
            .now(); // Fallback, mas não deve ser atingido com a lógica atual
    }

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate.isBefore(firstAllowedDate)
          ? firstAllowedDate
          : initialDate,
      firstDate: firstAllowedDate,
      lastDate: DateTime(DateTime.now().year + 1),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: kPrimaryColor,
              onPrimary: kLightTextColor,
              onSurface: kDarkTextColor,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: kPrimaryColor),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initialDate),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: kPrimaryColor,
                  onPrimary: kLightTextColor,
                  onSurface: kDarkTextColor,
                  surface: kScaffoldBackgroundColor,
                ),
                timePickerTheme: TimePickerThemeData(
                  backgroundColor: kScaffoldBackgroundColor,
                  hourMinuteTextColor: kPrimaryColor,
                  dialHandColor: kPrimaryColor,
                  dayPeriodTextColor: kAccentColor,
                  helpTextStyle: const TextStyle(color: kAccentColor),
                  cancelButtonStyle:
                      TextButton.styleFrom(foregroundColor: kAccentColor),
                  confirmButtonStyle:
                      TextButton.styleFrom(foregroundColor: kPrimaryColor),
                )),
            child: child!,
          );
        },
      );
      if (pickedTime != null) {
        if (mounted) {
          setState(() {
            DateTime newDateTime = DateTime(pickedDate.year, pickedDate.month,
                pickedDate.day, pickedTime.hour, pickedTime.minute);
            if (dateType == 3) {
              // Data de Reserva
              _reservationDate = newDateTime;
              // Se a nova data de reserva for depois da data de devolução, ajustar devolução
              if (_reservationDate.isAfter(_returnDate)) {
                _returnDate = _reservationDate
                    .add(const Duration(hours: 1)); // Ex: padrão 1h depois
              }
            } else if (dateType == 2) {
              // Data de Devolução
              _returnDate = newDateTime;
            }
            // dateType 1 não é chamado
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kScaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kLightTextColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Reserva por QR Code", // Título mais específico
            style: const TextStyle(
                color: kLightTextColor, fontWeight: FontWeight.bold)),
        elevation: 1.0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderImage(),
            const SizedBox(height: 24.0),
            const Text(
              "Reservar Material via QR Code",
              style: TextStyle(
                  color: kDarkTextColor,
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20.0),
            _buildScanButtonAndInfo(), // Botão de scan e info do material
            const SizedBox(height: 20.0),
            _buildDateField("Data da Solicitação", _requestDate, null, true,
                Icons.event_note_outlined),
            const SizedBox(height: 20.0),
            _buildDateField(
                "Início da Reserva",
                _reservationDate, // Usando _reservationDate
                () => _selectDateAndTime(context, 3),
                false,
                Icons.calendar_today_outlined),
            const SizedBox(height: 20.0),
            _buildDateField(
                "Fim da Reserva (Devolução)",
                _returnDate,
                () => _selectDateAndTime(context, 2),
                false,
                Icons.event_busy_outlined),
            const SizedBox(height: 30.0),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15.0),
      child: Image.asset(
        "images/agendamento.png", // Mantenha sua imagem
        width: double.infinity,
        height: 180.0,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: double.infinity,
            height: 180.0,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: const Center(
                child: Icon(Icons.qr_code_scanner_outlined,
                    color: Colors.grey, size: 60)),
          );
        },
      ),
    );
  }

  Widget _buildScanButtonAndInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Material (via QR Code)",
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: kDarkTextColor)),
        const SizedBox(height: 8),
        InkWell(
          onTap: _isProcessingScan
              ? null
              : scanQRCode, // Desabilita tap durante processamento
          borderRadius: BorderRadius.circular(12.0),
          child: Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 15.0),
            decoration: BoxDecoration(
              color: kCardBackgroundColor,
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: kAccentColor.withOpacity(0.7)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.15),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: _isProcessingScan
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.5, color: kPrimaryColor)),
                      SizedBox(width: 12),
                      Text("Processando QR Code...",
                          style:
                              TextStyle(fontSize: 16, color: kDisabledColor)),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              selectedMaterialName ??
                                  "Nenhum material escaneado",
                              style: TextStyle(
                                  color: selectedMaterialName ==
                                              'Material não encontrado' ||
                                          selectedMaterialName ==
                                              'Erro na busca'
                                      ? Colors.redAccent
                                      : kDarkTextColor,
                                  fontSize: 17.0,
                                  fontWeight: FontWeight.w500),
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (selectedMaterialId != null &&
                                selectedMaterialName !=
                                    'Material não encontrado' &&
                                selectedMaterialName != 'Erro na busca')
                              Text("ID: $selectedMaterialId",
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600))
                          ],
                        ),
                      ),
                      const Icon(Icons.qr_code_scanner_rounded,
                          color: kPrimaryColor, size: 28.0),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField(String label, DateTime date, VoidCallback? onTap,
      bool isReadOnly, IconData prefixIcon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: kDarkTextColor)),
        const SizedBox(height: 8),
        InkWell(
          onTap: isReadOnly ? null : onTap,
          borderRadius: BorderRadius.circular(12.0),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 15.0),
            decoration: BoxDecoration(
              color: isReadOnly
                  ? kDisabledColor.withOpacity(0.1)
                  : kCardBackgroundColor,
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(
                  color: isReadOnly
                      ? kDisabledColor.withOpacity(0.3)
                      : kAccentColor.withOpacity(0.5)),
              boxShadow: isReadOnly
                  ? []
                  : [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(prefixIcon,
                        color: isReadOnly ? kDisabledColor : kPrimaryColor,
                        size: 22.0),
                    const SizedBox(width: 10.0),
                    Text(
                      _dateTimeFormatter.format(date),
                      style: TextStyle(
                          color: isReadOnly
                              ? kDisabledColor.withOpacity(0.8)
                              : kDarkTextColor,
                          fontSize: 17.0,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                if (!isReadOnly)
                  Icon(Icons.edit_calendar_outlined,
                      color: kPrimaryColor, size: 22.0),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        padding: EdgeInsets.zero,
        elevation: _isLoadingSave ? 0 : 8,
        shadowColor: kPrimaryColor.withOpacity(0.4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ).copyWith(
        backgroundColor: MaterialStateProperty.all(Colors.transparent),
      ),
      onPressed: _isLoadingSave || _isProcessingScan
          ? null
          : saveReservation, // Desabilita se estiver processando scan também
      child: Ink(
        decoration: BoxDecoration(
          gradient: _isLoadingSave ||
                  _isProcessingScan // Mantém gradiente se não estiver carregando
              ? null
              : const LinearGradient(colors: [kPrimaryColor, kAccentColor]),
          color:
              _isLoadingSave || _isProcessingScan ? Colors.grey.shade400 : null,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          alignment: Alignment.center,
          child: _isLoadingSave
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 2.5,
                  ),
                )
              : const Text(
                  "SALVAR RESERVA",
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
}
