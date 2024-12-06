import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://api.sebastian.cl/oirs-utem';
  static String? apiToken;

  static void setApiToken(String token) {
    apiToken = token;
  }

  Future<List<dynamic>> fetchCategories() async {
    final response = await http.get(
      Uri.parse('$baseUrl/v1/info/categories'),
      headers: {'Authorization': 'Bearer $apiToken'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Error al obtener categorías');
    }
  }

  Future<List<dynamic>> fetchTickets(
      String categoryToken, String type, String status) async {
    final response = await http.get(
      Uri.parse(
          '$baseUrl/v1/icso/$categoryToken/tickets?type=$type&status=$status'),
      headers: {'Authorization': 'Bearer $apiToken'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Error al obtener tickets para la categoría');
    }
  }

  Future<void> respondToTicket(
      String ticketToken, String newStatus, String responseMessage) async {
    final response = await http.put(
      Uri.parse('$baseUrl/v1/response/$ticketToken/ticket'),
      headers: {
        'Authorization': 'Bearer $apiToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "status": newStatus,
        "response": responseMessage,
      }),
    );

    if (response.statusCode != 202) {
      // throw Exception('Error al responder el ticket: ${response.body}');
      throw ('No se puede modificar el estado del Ticket. Prueba con otro estado.');
    }
  }

  Future<Map<String, dynamic>> fetchTicketDetails(String ticketToken) async {
    final response = await http.get(
      Uri.parse('$baseUrl/v1/icso/$ticketToken/ticket'),
      headers: {'Authorization': 'Bearer $apiToken'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Error al obtener los detalles del ticket');
    }
  }

  Future<Map<String, dynamic>> fetchAttachment(
      String ticketToken, String attachmentToken) async {
    final response = await http.get(
      Uri.parse('$baseUrl/v1/attachments/$ticketToken/$attachmentToken'),
      headers: {'Authorization': 'Bearer $apiToken'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Error al obtener el archivo adjunto');
    }
  }

  Future<void> deleteTicket(String ticketToken) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/v1/icso/$ticketToken/ticket'),
      headers: {'Authorization': 'Bearer $apiToken'},
    );

    if (response.statusCode != 204) {
      throw Exception('Error al eliminar el ticket');
    }
  }
}
