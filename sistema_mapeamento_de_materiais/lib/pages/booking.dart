import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sistema_mapeamento_de_materiais/services/database.dart';
import 'package:sistema_mapeamento_de_materiais/services/shared_pref.dart';

class Booking extends StatefulWidget {
  final String service;
  Booking({required this.service});

  @override
  State<Booking> createState() => _BookingState();
}

class _BookingState extends State<Booking> {
  String? name, email, userId;
  String? selectedRoom;
  String? selectedLocation;
  String? selectedRoomId; // Adicionando o ID da sala

  List<String> roomList = [];
  List<String> locationList = [];

  DateTime _selectedDate = DateTime.now();
  DateTime _requestDate = DateTime.now();
  DateTime _returnDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    getUserData();
    fetchLocationData();
  }

  getUserData() async {
    name = await SharedpreferenceHelper().getUserName();
    email = await SharedpreferenceHelper().getUserEmail();
    userId = await SharedpreferenceHelper().getUserId();
    setState(() {});
  }

  Future<void> fetchLocationData() async {
    try {
      QuerySnapshot locationSnapshot = await FirebaseFirestore.instance.collection("salas").get();
      locationList = locationSnapshot.docs.map((doc) => doc['local'] as String).toSet().toList();
      setState(() {});
    } catch (e) {
      print("Erro ao buscar dados de locais: $e");
    }
  }

  Future<void> fetchRoomData(String location) async {
    try {
      QuerySnapshot roomSnapshot = await FirebaseFirestore.instance
          .collection("salas")
          .where('local', isEqualTo: location)
          .get();
      roomList = roomSnapshot.docs.map((doc) => doc['nome_da_sala'] as String).toList();

      if (roomList.isEmpty) {
        selectedRoom = null; // Reset selected room if no rooms found
      } else {
        // Atribuindo o ID da sala ao selecionar a sala
        selectedRoomId = roomSnapshot.docs.first.id; // Armazena o documentId da sala
      }

      setState(() {});
    } catch (e) {
      print("Erro ao buscar dados de salas para o local: $e");
    }
  }

  Future<void> saveReservation() async {
    if (selectedRoom != null && selectedLocation != null && selectedRoomId != null) {
      try {
        await FirebaseFirestore.instance.collection("reservas").add({
          'usuarios_id': userId,
          'salas_id': selectedRoomId, // Agora salvando o ID correto da sala
          'sala': selectedRoom,
          'local': selectedLocation,
          'data_solicitacao': _requestDate,
          'data_reserva': _selectedDate,
          'data_devolucao': _returnDate,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Reserva realizada com sucesso!")),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao realizar a reserva: $e")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Por favor, preencha todos os campos!")),
      );
    }
  }

  Future<void> _selectDateAndTime(BuildContext context, int dateType) async {
    DateTime initialDate = dateType == 1 ? _selectedDate : (dateType == 2 ? _requestDate : _returnDate);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2026),
    );
    if (picked != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initialDate),
      );
      if (pickedTime != null) {
        setState(() {
          if (dateType == 1) {
            _selectedDate = DateTime(picked.year, picked.month, picked.day, pickedTime.hour, pickedTime.minute);
          } else if (dateType == 2) {
            _requestDate = DateTime(picked.year, picked.month, picked.day, pickedTime.hour, pickedTime.minute);
          } else {
            _returnDate = DateTime(picked.year, picked.month, picked.day, pickedTime.hour, pickedTime.minute);
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0000FF),
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Reserva de ${widget.service}", style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Vamos fazer a Reserva",
                style: TextStyle(color: Colors.white70, fontSize: 28.0, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 20.0),
              Image.asset(
                "images/agendamento.png",
                width: double.infinity,
                height: 200.0,
                fit: BoxFit.cover,
              ),
              SizedBox(height: 20.0),
              Text(
                widget.service,
                style: TextStyle(color: Colors.white, fontSize: 25.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20.0),
              _buildDropdown("Escolha o Local", locationList, selectedLocation, (value) {
                setState(() {
                  selectedLocation = value;
                  fetchRoomData(value!);
                });
              }),
              SizedBox(height: 20.0),
              _buildDropdown("Escolha a Sala", roomList, selectedRoom, (value) {
                setState(() {
                  selectedRoom = value;
                });
              }),
              SizedBox(height: 20.0),
              _buildDateField("Data da Solicitação", _requestDate, null, true),
              SizedBox(height: 20.0),
              _buildDateField("Defina uma data de reserva", _selectedDate, () => _selectDateAndTime(context, 1), false),
              SizedBox(height: 20.0),
              _buildDateField("Data da Devolução", _returnDate, () => _selectDateAndTime(context, 3), false),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: saveReservation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: Size(double.infinity, 50),
                ),
                child: Text("Salvar Reserva", style: TextStyle(fontSize: 18.0)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateField(String label, DateTime date, VoidCallback? onTap, bool isReadOnly) {
    return Container(
      padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
      decoration: BoxDecoration(
        color: Color(0xFFb4817e),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              label,
              style: TextStyle(color: Colors.black, fontSize: 20.0, fontWeight: FontWeight.w500),
            ),
          ),
          SizedBox(height: 10.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!isReadOnly)
                GestureDetector(
                  onTap: onTap,
                  child: Icon(Icons.calendar_month, color: Colors.white, size: 30.0),
                ),
              SizedBox(width: 20.0),
              Text(
                "${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}",
                style: TextStyle(color: isReadOnly ? Colors.black : Colors.white, fontSize: 30.0, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items, String? value, Function(String?) onChanged) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.0),
      decoration: BoxDecoration(
        color: Color(0xFFb4817e),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              label,
              style: TextStyle(color: Colors.black, fontSize: 20.0, fontWeight: FontWeight.w500),
            ),
          ),
          SizedBox(height: 10.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: DropdownButton<String>(
              isExpanded: true,
              value: value,
              hint: Text("Selecione"),
              icon: Icon(Icons.arrow_downward, color: Colors.black),
              elevation: 16,
              style: TextStyle(color: Colors.black, fontSize: 18.0),
              underline: Container(
                height: 2,
                color: Colors.black,
              ),
              onChanged: onChanged,
              items: items.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
