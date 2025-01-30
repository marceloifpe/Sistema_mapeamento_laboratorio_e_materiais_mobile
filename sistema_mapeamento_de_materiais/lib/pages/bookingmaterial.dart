import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sistema_mapeamento_de_materiais/services/shared_pref.dart';

class BookingMaterial extends StatefulWidget {
  final String service;

  BookingMaterial({required this.service});

  @override
  State<BookingMaterial> createState() => _BookingMaterialState();
}

class _BookingMaterialState extends State<BookingMaterial> {
  String? name, email, userId;
  String? selectedMaterialName;
  String? selectedMaterialId;
  List<Map<String, String>> materialsList = [];

  DateTime _selectedDate = DateTime.now();
  DateTime _requestDate = DateTime.now();
  DateTime _returnDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    getUserData();
    fetchMaterialsData();
  }

  getUserData() async {
    name = await SharedpreferenceHelper().getUserName();
    email = await SharedpreferenceHelper().getUserEmail();
    userId = await SharedpreferenceHelper().getUserId();
    setState(() {});
  }

  Future<void> fetchMaterialsData() async {
    try {
      QuerySnapshot materialsSnapshot = await FirebaseFirestore.instance.collection("materiais").get();
      materialsList = materialsSnapshot.docs
          .map((doc) => {'id': doc.id, 'name': doc['nome_do_material'] as String})
          .toList();
      setState(() {});
    } catch (e) {
      print("Erro ao buscar dados de materiais: $e");
    }
  }

  Future<void> saveReservation() async {
    if (selectedMaterialName != null && selectedMaterialId != null) {
      try {
        await FirebaseFirestore.instance.collection("reserva").add({
          'usuarios_id': userId,
          'material_id': selectedMaterialId,
          'material_nome': selectedMaterialName,
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
              _buildDropdown(
                "Escolha o Material",
                materialsList.map((m) => m['name']!).toList(),
                selectedMaterialName,
                (value) {
                  setState(() {
                    selectedMaterialName = value;
                    selectedMaterialId = materialsList.firstWhere((m) => m['name'] == value)['id'];
                  });
                },
              ),
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
              items: items.map<DropdownMenuItem<String>>((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
