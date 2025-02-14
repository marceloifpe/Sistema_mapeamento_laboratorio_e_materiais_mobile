import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sistema_mapeamento_de_materiais/services/shared_pref.dart';
import 'QRScannerScreen.dart';

class ReservaMaterial extends StatefulWidget {
  final String service;

  ReservaMaterial({required this.service});

  @override
  State<ReservaMaterial> createState() => _ReservaMaterialState();
}

class _ReservaMaterialState extends State<ReservaMaterial> {
  String? name, email, userId;
  String? selectedMaterialName;
  String? selectedMaterialId;
  DateTime _requestDate = DateTime.now();
  DateTime _returnDate = DateTime.now();
  DateTime _reservationDate = DateTime.now(); // Adicionando a data da reserva

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  // Função para buscar dados do usuário
  getUserData() async {
    name = await SharedpreferenceHelper().getUserName();
    email = await SharedpreferenceHelper().getUserEmail();
    userId = await SharedpreferenceHelper().getUserId();
    setState(() {});
  }

  // Função para buscar material pelo ID do QR Code
  Future<void> fetchMaterialById(String scannedQrCode) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("materiais")
          .where("qr_code", isEqualTo: scannedQrCode) // Busca pelo QR Code
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var materialData = querySnapshot.docs.first;
        setState(() {
          selectedMaterialId = materialData.id; // ID do documento
          selectedMaterialName = materialData['nome_do_material']; // Nome do material
        });

        // Mensagem de sucesso ao encontrar o material
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Material encontrado: ${materialData['nome_do_material']}")),
        );
      } else {
        setState(() {
          selectedMaterialId = null;
          selectedMaterialName = 'Material não encontrado';
        });

        // Mensagem caso não encontre o material
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Material não encontrado. Verifique o QR Code.")),
        );
      }
    } catch (e) {
      print("Erro ao buscar material: $e");

      // Exibe erro ao usuário se houver falha na busca
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao buscar material. Tente novamente.")),
      );
    }
  }

  // Função para escanear o QR Code
  Future<void> scanQRCode() async {
    final scannedMaterialId = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => QRScannerScreen(
          onScan: (result) {
            if (result != null && result.isNotEmpty) {
              setState(() {
                selectedMaterialId = result;
              });
              fetchMaterialById(result); // Busca o material após escanear
            }
          },
        ),
      ),
    );

    if (scannedMaterialId != null && scannedMaterialId.isNotEmpty) {
      setState(() {
        selectedMaterialId = scannedMaterialId;
      });
      fetchMaterialById(scannedMaterialId); // Busca o material após escanear
    }
  }

  // Função para salvar a reserva
  Future<void> saveReservation() async {
    if (selectedMaterialName != null && selectedMaterialId != null) {
      try {
        await FirebaseFirestore.instance.collection("reserva").add({
          'usuarios_id': userId,
          'material_id': selectedMaterialId,
          'material_nome': selectedMaterialName,
          'data_solicitacao': _requestDate,
          'data_reserva': _reservationDate, // Salvando a data de reserva
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

  // Função para selecionar datas e horários
  Future<void> _selectDateAndTime(BuildContext context, int dateType) async {
    DateTime initialDate = DateTime.now(); // Padrão para a data inicial

    if (dateType == 1) {
      initialDate = _requestDate;
    } else if (dateType == 2) {
      initialDate = _returnDate;
    } else if (dateType == 3) {
      initialDate = _reservationDate; // Para data de reserva
    }

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
            _requestDate = DateTime(picked.year, picked.month, picked.day, pickedTime.hour, pickedTime.minute);
          } else if (dateType == 2) {
            _returnDate = DateTime(picked.year, picked.month, picked.day, pickedTime.hour, pickedTime.minute);
          } else if (dateType == 3) {
            _reservationDate = DateTime(picked.year, picked.month, picked.day, pickedTime.hour, pickedTime.minute);
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
              // Mensagem "Vamos fazer a Reserva"
              Text(
                "Vamos fazer a Reserva",
                style: TextStyle(color: Colors.white70, fontSize: 28.0, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 20.0),

              // Imagem de agendamento
              Image.asset('images/agendamento.png', height: 200.0, width: double.infinity, fit: BoxFit.cover),

              SizedBox(height: 20.0),
              GestureDetector(
                onTap: scanQRCode,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "Escanear QR Code",
                        style: TextStyle(color: Colors.black, fontSize: 20.0, fontWeight: FontWeight.w500),
                      ),
                      SizedBox(height: 10.0),
                      Text(
                        selectedMaterialName ?? "Nenhum material selecionado",
                        style: TextStyle(color: Colors.black, fontSize: 18.0),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20.0),
              _buildDateField("Data da Solicitação", _requestDate, null, true),
              SizedBox(height: 20.0),
              _buildDateField("Defina uma data de Reserva", _reservationDate, () => _selectDateAndTime(context, 3), false), // Permite alterar a data da reserva
              SizedBox(height: 20.0),
              _buildDateField("Data da Devolução", _returnDate, () => _selectDateAndTime(context, 2), false),
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

  // Função para construir o campo de data
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
                  child: Icon(Icons.calendar_today, color: Colors.white),
                ),
              SizedBox(width: 20.0),
              Text(
                "${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}",
                style: TextStyle(color: Colors.black, fontSize: 20.0),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
