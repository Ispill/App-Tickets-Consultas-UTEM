import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'ticket_detail_screen.dart';

class TicketsScreen extends StatelessWidget {
  final String categoryToken;
  final String categoryName;
  final String type; // Tipo de ticket
  final String status; // Estado del ticket

  TicketsScreen({
    required this.categoryToken,
    required this.categoryName,
    required this.type,
    required this.status,
  });

  final ApiService apiService = ApiService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tickets de $categoryName')),
      body: FutureBuilder<List<dynamic>>(
        future: apiService.fetchTickets(categoryToken, type, status),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(
              child: Text(
                'No hay tickets disponibles para el estado y tipo seleccionado.',
                textAlign: TextAlign.center,
              ),
            );
          } else if (snapshot.hasData) {
            final tickets = snapshot.data!;
            return ListView.builder(
              itemCount: tickets.length,
              itemBuilder: (context, index) {
                final ticket = tickets[index];
                return ListTile(
                  title: Text('Ticket: ${ticket['token']}'),
                  subtitle: Text('Estado: ${ticket['status']}'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            TicketDetailScreen(ticketToken: ticket['token']),
                      ),
                    );
                  },
                );
              },
            );
          } else {
            return Center(child: Text('No hay tickets disponibles'));
          }
        },
      ),
    );
  }
}
