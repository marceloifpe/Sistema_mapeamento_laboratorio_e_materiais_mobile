import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Para formatação de data e hora
import 'package:sistema_mapeamento_de_materiais/services/shared_pref.dart';

class BookingMaterial extends StatefulWidget {
  final String service;

  BookingMaterial({required this.service, super.key});

  @override
  State<BookingMaterial> createState() => _BookingMaterialState();
}

class _BookingMaterialState extends State<BookingMaterial> {
  String? name, email, userId;
  String? selectedMaterialName;
  String? selectedMaterialId;
  List<Map<String, String>> materialsList = [];

  DateTime _requestDate = DateTime.now();
  DateTime _selectedDate = DateTime.now().add(const Duration(hours: 1));
  DateTime _returnDate = DateTime.now().add(const Duration(days: 1));

  bool _isLoadingSave = false;
  bool _isFetchingMaterials = true;

  static const Color kPrimaryColor = Color(0xFF091057);
  static const Color kAccentColor = Color(0xff1F509A);
  static const Color kLightTextColor = Colors.white;
  static const Color kDarkTextColor = Colors.black87;
  static const Color kScaffoldBackgroundColor = Color(0xFFF4F6F8);
  static const Color kCardBackgroundColor = Colors.white;
  static const Color kDisabledColor = Colors.grey;

  final DateFormat _dateTimeFormatter = DateFormat('dd/MM/yyyy HH:mm');

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await getUserData();
    await fetchMaterialsData();
  }

  Future<void> getUserData() async {
    name = await SharedpreferenceHelper().getUserName();
    email = await SharedpreferenceHelper().getUserEmail();
    userId = await SharedpreferenceHelper().getUserId();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> fetchMaterialsData() async {
    if (mounted) {
      setState(() {
        _isFetchingMaterials = true;
      });
    }
    try {
      QuerySnapshot materialsSnapshot =
          await FirebaseFirestore.instance.collection("materiais").get();
      if (mounted) {
        materialsList = materialsSnapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  'name':
                      doc['nome_do_material'] as String? ?? 'Nome Indisponível'
                })
            .toList();
        setState(() {
          _isFetchingMaterials = false;
        });
      }
    } catch (e) {
      print("Erro ao buscar dados de materiais: $e");
      if (mounted) {
        setState(() {
          _isFetchingMaterials = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              backgroundColor: Colors.redAccent,
              content: Text("Erro ao carregar materiais: $e",
                  style: const TextStyle(color: kLightTextColor))),
        );
      }
    }
  }

  Future<void> saveReservation() async {
    if (selectedMaterialName == null || selectedMaterialId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            backgroundColor: Colors.orangeAccent,
            content: Text(
                "Por favor, selecione um material e verifique as datas.",
                style: TextStyle(color: kLightTextColor))),
      );
      return;
    }
    if (_selectedDate.isBefore(_requestDate) ||
        _returnDate.isBefore(_selectedDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            backgroundColor: Colors.orangeAccent,
            content: Text("Datas inválidas. Verifique a ordem e os horários.",
                style: TextStyle(color: kLightTextColor))),
      );
      return;
    }

    if (mounted) {
      setState(() {
        _isLoadingSave = true;
      });
    }

    try {
      // ##### CORREÇÃO AQUI: Estrutura de dados original para salvar no Firebase #####
      await FirebaseFirestore.instance.collection("reserva").add({
        'usuarios_id': userId,
        'material_id': selectedMaterialId,
        'material_nome': selectedMaterialName,
        'data_solicitacao': _requestDate,
        'data_reserva': _selectedDate,
        'data_devolucao': _returnDate,
      });
      // ################################################################
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              backgroundColor: Colors.green,
              content: Text("Reserva realizada com sucesso!",
                  style: TextStyle(color: kLightTextColor))),
        );
        Navigator.pop(context);
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
      if (mounted) {
        setState(() {
          _isLoadingSave = false;
        });
      }
    }
  }

  Future<void> _selectDateAndTime(BuildContext context, int dateType) async {
    DateTime initialDate;
    DateTime firstAllowedDate =
        DateTime.now().subtract(const Duration(days: 1));

    switch (dateType) {
      case 1:
        initialDate = _selectedDate;
        firstAllowedDate = _requestDate;
        break;
      case 2:
        initialDate = _requestDate;
        break;
      case 3:
        initialDate = _returnDate;
        firstAllowedDate = _selectedDate;
        break;
      default:
        initialDate = DateTime.now();
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
            if (dateType == 1) {
              _selectedDate = newDateTime;
              if (_selectedDate.isAfter(_returnDate)) {
                _returnDate = _selectedDate.add(const Duration(hours: 1));
              }
            } else if (dateType == 2) {
              // _requestDate = newDateTime; // Geralmente não alterada pelo picker
            } else {
              _returnDate = newDateTime;
            }
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
        title: Text("Reserva de ${widget.service}",
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
            Text(
              "Detalhes da Reserva para ${widget.service}",
              style: const TextStyle(
                  color: kDarkTextColor,
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20.0),
            _buildDropdown(
              "Material Desejado",
              Icons.category_outlined,
              materialsList.map((m) => m['name']!).toList(),
              selectedMaterialName,
              (value) {
                if (mounted) {
                  setState(() {
                    selectedMaterialName = value;
                    selectedMaterialId = materialsList
                        .firstWhere((m) => m['name'] == value)['id'];
                  });
                }
              },
              isLoading: _isFetchingMaterials,
            ),
            const SizedBox(height: 20.0),
            _buildDateField("Data da Solicitação", _requestDate, null, true,
                Icons.event_note_outlined),
            const SizedBox(height: 20.0),
            _buildDateField(
                "Início da Reserva",
                _selectedDate,
                () => _selectDateAndTime(context, 1),
                false,
                Icons.calendar_today_outlined),
            const SizedBox(height: 20.0),
            _buildDateField(
                "Fim da Reserva (Devolução)",
                _returnDate,
                () => _selectDateAndTime(context, 3),
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
        "images/agendamento.png",
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
                child: Icon(Icons.image_not_supported_outlined,
                    color: Colors.grey, size: 50)),
          );
        },
      ),
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

  Widget _buildDropdown(String label, IconData prefixIcon, List<String> items,
      String? value, Function(String?) onChanged,
      {bool isLoading = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: kDarkTextColor)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 5.0),
          decoration: BoxDecoration(
            color: kCardBackgroundColor,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(color: kAccentColor.withOpacity(0.5)),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: isLoading
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Row(
                    children: [
                      SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.5, color: kPrimaryColor)),
                      SizedBox(width: 12),
                      Text("Carregando materiais...",
                          style:
                              TextStyle(color: kDisabledColor, fontSize: 16)),
                    ],
                  ),
                )
              : DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: value,
                    hint: const Text("Selecione o material",
                        style: TextStyle(color: kDisabledColor)),
                    icon: Icon(Icons.arrow_drop_down_circle_outlined,
                        color: kPrimaryColor),
                    elevation: 8,
                    style: const TextStyle(
                        color: kDarkTextColor,
                        fontSize: 17.0,
                        fontWeight: FontWeight.w500),
                    dropdownColor: kCardBackgroundColor,
                    borderRadius: BorderRadius.circular(12.0),
                    items: items.map<DropdownMenuItem<String>>((String item) {
                      return DropdownMenuItem<String>(
                        value: item,
                        child: Text(item),
                      );
                    }).toList(),
                    onChanged: onChanged,
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
      onPressed: _isLoadingSave ? null : saveReservation,
      child: Ink(
        decoration: BoxDecoration(
          gradient: _isLoadingSave
              ? null
              : const LinearGradient(colors: [kPrimaryColor, kAccentColor]),
          color: _isLoadingSave ? Colors.grey.shade400 : null,
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
