import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Para formatação de data e hora
import 'package:sistema_mapeamento_de_materiais/services/shared_pref.dart';

class Booking extends StatefulWidget {
  final String service; // Ex: "Sala"
  Booking({required this.service, super.key});

  @override
  State<Booking> createState() => _BookingState();
}

class _BookingState extends State<Booking> {
  String? name, email, userId;
  String? selectedRoom; // Nome da sala selecionada (como no original)
  String? selectedLocation; // Nome do local selecionado (como no original)
  String?
      selectedRoomId; // ID do documento da sala (determinado pela lógica original)

  List<String> roomList = []; // Lista de nomes de salas (como no original)
  List<String> locationList = []; // Lista de nomes de locais (como no original)

  DateTime _requestDate = DateTime.now();
  DateTime _selectedDate = DateTime.now().add(const Duration(hours: 1));
  DateTime _returnDate = DateTime.now().add(const Duration(days: 1));

  bool _isLoadingSave = false;
  bool _isFetchingLocations = true;
  bool _isFetchingRooms = false;

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
    await fetchLocationData();
  }

  Future<void> getUserData() async {
    name = await SharedpreferenceHelper().getUserName();
    email = await SharedpreferenceHelper().getUserEmail();
    userId = await SharedpreferenceHelper().getUserId();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> fetchLocationData() async {
    if (mounted) setState(() => _isFetchingLocations = true);
    try {
      QuerySnapshot locationSnapshot =
          await FirebaseFirestore.instance.collection("salas").get();
      if (mounted) {
        locationList = locationSnapshot.docs
            .map((doc) => doc['local'] as String? ?? 'Local Desconhecido')
            .toSet() // Para pegar apenas nomes únicos de locais
            .toList();
        setState(() => _isFetchingLocations = false);
      }
    } catch (e) {
      print("Erro ao buscar dados de locais: $e");
      if (mounted) {
        setState(() => _isFetchingLocations = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              backgroundColor: Colors.redAccent,
              content: Text("Erro ao carregar locais: $e",
                  style: const TextStyle(color: kLightTextColor))),
        );
      }
    }
  }

  // Lógica de fetchRoomData e atribuição de selectedRoomId restaurada para o original
  Future<void> fetchRoomData(String location) async {
    if (mounted) {
      setState(() {
        _isFetchingRooms = true;
        selectedRoom = null; // Reseta a sala selecionada ao mudar o local
        selectedRoomId = null; // Reseta o ID da sala
        roomList = []; // Limpa a lista de nomes de salas
      });
    }
    try {
      QuerySnapshot roomSnapshot = await FirebaseFirestore.instance
          .collection("salas")
          .where('local', isEqualTo: location)
          .get();

      if (mounted) {
        roomList = roomSnapshot.docs
            .map((doc) => doc['nome_da_sala'] as String? ?? 'Sala Desconhecida')
            .toList();

        if (roomList.isEmpty) {
          selectedRoom = null;
          selectedRoomId = null; // Garante que ID também seja nulo
        } else {
          // LÓGICA ORIGINAL RESTAURADA:
          // selectedRoomId é o ID do PRIMEIRO documento da sala encontrado para o local.
          // Este ID será usado para salvar, mesmo que o usuário escolha outro nome de sala no dropdown.
          selectedRoomId = roomSnapshot.docs.first.id;
          // Opcional: pré-selecionar o nome da primeira sala no dropdown.
          // Se o seu dropdown original não pré-selecionava, pode remover a linha abaixo.
          // selectedRoom = roomList.first;
        }
        setState(() => _isFetchingRooms = false);
      }
    } catch (e) {
      print("Erro ao buscar dados de salas para o local $location: $e");
      if (mounted) {
        setState(() => _isFetchingRooms = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              backgroundColor: Colors.redAccent,
              content: Text("Erro ao carregar salas: $e",
                  style: const TextStyle(color: kLightTextColor))),
        );
      }
    }
  }

  Future<void> saveReservation() async {
    if (selectedRoom != null &&
        selectedLocation != null &&
        selectedRoomId != null) {
      // A validação de datas e outros campos já foi feita visualmente
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            backgroundColor: Colors.orangeAccent,
            content: Text(
                "Por favor, selecione local, sala e verifique as datas.",
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

    if (mounted) setState(() => _isLoadingSave = true);

    try {
      // Estrutura de salvamento EXATAMENTE como no seu original para 'reservas'
      await FirebaseFirestore.instance.collection("reservas").add({
        'usuarios_id': userId,
        'salas_id': selectedRoomId, // ID da *primeira* sala do local
        'sala': selectedRoom, // Nome da sala escolhida no dropdown
        'local': selectedLocation, // Nome do local
        'data_solicitacao': _requestDate,
        'data_reserva': _selectedDate,
        'data_devolucao': _returnDate,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              backgroundColor: Colors.green,
              content: Text("Reserva de sala realizada com sucesso!",
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
      if (mounted) setState(() => _isLoadingSave = false);
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
              // Dropdown para Local
              "Selecione o Local",
              Icons.location_city_outlined,
              locationList, // Usando locationList (List<String>)
              selectedLocation,
              (value) {
                if (value != null && mounted) {
                  setState(() {
                    selectedLocation = value;
                    // Limpar seleção de sala anterior e buscar novas salas
                    selectedRoom = null;
                    selectedRoomId = null; // Importante resetar o ID também
                    roomList = []; // Limpa a lista de nomes de salas
                    if (selectedLocation != null) {
                      // Verifica se selectedLocation não é nulo
                      fetchRoomData(selectedLocation!);
                    }
                  });
                }
              },
              isLoading: _isFetchingLocations,
              hintText: "Escolha um local",
            ),
            const SizedBox(height: 20.0),
            _buildDropdown(
              // Dropdown para Sala
              "Selecione a Sala",
              Icons.meeting_room_outlined,
              roomList, // Usando roomList (List<String>)
              selectedRoom,
              (value) {
                // Este onChanged apenas define o NOME da sala selecionada
                if (value != null && mounted) {
                  setState(() {
                    selectedRoom = value;
                    // NÃO definimos selectedRoomId aqui, pois a lógica original
                    // o define em fetchRoomData como o ID da primeira sala do local.
                  });
                }
              },
              isLoading: _isFetchingRooms,
              hintText: selectedLocation == null
                  ? "Primeiro escolha um local"
                  : "Escolha uma sala",
              disabled: selectedLocation == null,
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
                "Fim da Reserva",
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

  // Widgets _buildHeaderImage, _buildDateField, _buildDropdown, _buildSubmitButton
  // permanecem os mesmos que na versão anterior (com todas as melhorias visuais)
  // Apenas a assinatura e a lógica interna de _buildDropdown podem precisar de pequenos ajustes
  // se os tipos de lista mudaram, mas aqui mantivemos List<String> para os nomes dos itens.

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
      {bool isLoading = false,
      String hintText = "Selecione",
      bool disabled = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: disabled ? kDisabledColor : kDarkTextColor)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 5.0), // Ajuste de padding vertical para Dropdown
          decoration: BoxDecoration(
            color: disabled
                ? kDisabledColor.withOpacity(0.1)
                : kCardBackgroundColor,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
                color: disabled
                    ? kDisabledColor.withOpacity(0.3)
                    : kAccentColor.withOpacity(0.5)),
            boxShadow: disabled
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
                      Text(
                          hintText.startsWith("Carregando")
                              ? hintText
                              : "Carregando...",
                          style:
                              TextStyle(color: kDisabledColor, fontSize: 16)),
                    ],
                  ),
                )
              : DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: value,
                    hint: Text(hintText,
                        style: const TextStyle(color: kDisabledColor)),
                    icon: Icon(Icons.arrow_drop_down_circle_outlined,
                        color: disabled ? kDisabledColor : kPrimaryColor),
                    elevation: 8,
                    style: TextStyle(
                        color: disabled ? kDisabledColor : kDarkTextColor,
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
                    onChanged: disabled ? null : onChanged,
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
