import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {
  // Método para adicionar os detalhes do usuário
  Future<void> addUserDetails(Map<String, dynamic> userInfoMap, String id) async {
    try {
      await FirebaseFirestore.instance
          .collection("usuarios")
          .doc(id)
          .set(userInfoMap);
    } catch (e) {
      print("Erro ao adicionar detalhes do usuário: $e");
    }
  }

  // Método para adicionar uma reserva
  Future<void> addUserBooking(Map<String, dynamic> bookingInfoMap, String salaId) async {
    try {
      await FirebaseFirestore.instance
          .collection("reservas")
          .add({
            ...bookingInfoMap,
            "salaId": salaId,  // Adiciona o ID da sala associada à reserva
          });
    } catch (e) {
      print("Erro ao adicionar reserva: $e");
    }
  }

  // Método para adicionar detalhes de uma sala
  Future<void> addRoomDetails(Map<String, dynamic> roomInfoMap, String roomId) async {
    try {
      await FirebaseFirestore.instance
          .collection("salas")
          .doc(roomId)
          .set(roomInfoMap);
    } catch (e) {
      print("Erro ao adicionar detalhes da sala: $e");
    }
  }

  // Método para buscar informações de uma reserva junto com a sala
  Future<Map<String, dynamic>> getBookingWithRoomDetails(String bookingId) async {
    try {
      DocumentSnapshot bookingSnapshot = await FirebaseFirestore.instance
          .collection("reservas")
          .doc(bookingId)
          .get();

      if (bookingSnapshot.exists) {
        Map<String, dynamic> bookingData = bookingSnapshot.data() as Map<String, dynamic>;
        String salaId = bookingData["salaId"];  // ID da sala associada à reserva

        DocumentSnapshot roomSnapshot = await FirebaseFirestore.instance
            .collection("salas")
            .doc(salaId)
            .get();

        if (roomSnapshot.exists) {
          Map<String, dynamic> roomData = roomSnapshot.data() as Map<String, dynamic>;
          // Retorna as informações combinadas de reserva e sala
          return {
            "reserva": bookingData,
            "sala": roomData,
          };
        }
      }

      return {};  // Retorna um mapa vazio se não houver dados
    } catch (e) {
      print("Erro ao buscar reserva e detalhes da sala: $e");
      return {};
    }
  }
}
