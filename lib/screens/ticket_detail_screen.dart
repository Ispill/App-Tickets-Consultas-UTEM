import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:io';
import '../services/api_service.dart';

class TicketDetailScreen extends StatefulWidget {
  final String ticketToken;

  const TicketDetailScreen({super.key, required this.ticketToken});

  @override
  _TicketDetailScreenState createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  final ApiService apiService = ApiService();
  late Future<Map<String, dynamic>> ticketDetails;
  String selectedStatus = "null"; // Estado inicial por defecto.
  final TextEditingController responseController = TextEditingController();

  @override
  void initState() {
    super.initState();
    ticketDetails = apiService.fetchTicketDetails(widget.ticketToken);
  }

  Future<void> downloadAttachment(
      String ticketToken, String attachmentToken, String fileName) async {
    try {
      final attachment =
          await apiService.fetchAttachment(ticketToken, attachmentToken);

      final data = base64Decode(attachment['data']); // Decodifica el archivo
      final downloadDir = Directory('/storage/emulated/0/Download');
      final filePath = '${downloadDir.path}/$fileName';

      final file = File(filePath);
      await file.writeAsBytes(data); // Guarda el archivo localmente

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Archivo descargado: $filePath')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al descargar el archivo: $e')),
      );
    }
  }

  Future<void> copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('ID copiado al portapapeles')),
    );
  }

  Future<void> deleteTicket() async {
    try {
      await apiService.deleteTicket(widget.ticketToken);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ticket eliminado con éxito')),
      );
      Navigator.pop(
          context, true); // Regresa con éxito para actualizar la lista
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar el ticket: $e')),
      );
    }
  }

  Future<void> showDeleteConfirmationDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: const Text(
              '¿Estás seguro de que deseas eliminar este ticket? Esta acción no se puede deshacer.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false), // Cancelar
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true), // Confirmar
              child:
                  const Text('Eliminar', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await deleteTicket(); // Si se confirma, eliminar el ticket
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detalles del Ticket',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 14, 112, 107),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: ticketDetails,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final ticket = snapshot.data!;
            final attachedTokens = ticket['attachedTokens'] as List<dynamic>?;
            final estado = ticket['status'];

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'ID del ticket: ${widget.ticketToken}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.copy),
                                  onPressed: () =>
                                      copyToClipboard(widget.ticketToken),
                                  tooltip: 'Copiar ID',
                                ),
                              ],
                            ),
                            const Divider(color: Colors.black),
                            const SizedBox(height: 10),
                            Text(
                              ticket['subject'] == "<string>"
                                  ? 'No hay información'
                                  : '${ticket['subject'] ?? "No hay información"}',
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              ticket['message'] == "<string>"
                                  ? 'No hay información'
                                  : '${ticket['message'] ?? "No hay información"}',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (attachedTokens != null &&
                        attachedTokens.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Archivos Adjuntos',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.teal),
                              ),
                              const SizedBox(height: 10),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: attachedTokens.length,
                                itemBuilder: (context, index) {
                                  final attachmentToken = attachedTokens[index];
                                  return FutureBuilder<Map<String, dynamic>>(
                                    future: apiService.fetchAttachment(
                                        widget.ticketToken, attachmentToken),
                                    builder: (context, attachmentSnapshot) {
                                      if (attachmentSnapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const ListTile(
                                          title: Text('Cargando archivo...'),
                                        );
                                      } else if (attachmentSnapshot.hasError) {
                                        return const ListTile(
                                          title:
                                              Text('Error al cargar archivo'),
                                        );
                                      } else if (attachmentSnapshot.hasData) {
                                        final attachment =
                                            attachmentSnapshot.data!;
                                        final fileName = attachment['name'];

                                        return ListTile(
                                          title: Text(fileName),
                                          trailing: IconButton(
                                            icon: const Icon(Icons.download),
                                            onPressed: () => downloadAttachment(
                                                widget.ticketToken,
                                                attachmentToken,
                                                fileName),
                                          ),
                                        );
                                      } else {
                                        return const ListTile(
                                          title: Text('Archivo no disponible'),
                                        );
                                      }
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    if (ticket['response'] != null) ...[
                      const SizedBox(height: 10),
                      Center(
                        child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Respuesta de un administrativo',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.teal),
                                    textAlign: TextAlign.start,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    '${ticket['response']}',
                                    style: const TextStyle(
                                        fontSize: 16, color: Colors.black87),
                                  ),
                                ],
                              ),
                            )),
                      )
                    ],
                    if (estado != "RESOLVED" &&
                        estado != "CLOSED" &&
                        estado != "REJECTED" &&
                        estado != "CANCELLED") ...[
                      const SizedBox(height: 10),
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Cambiar estado del ticket',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.teal),
                              ),
                              const SizedBox(height: 10),
                              DropdownButtonFormField<String>(
                                value: selectedStatus,
                                items: const [
                                  DropdownMenuItem(
                                      value: "null",
                                      child: Text('Seleccionar un estado')),
                                  DropdownMenuItem(
                                      value: "UNDER_REVIEW",
                                      child: Text('En Revisión')),
                                  DropdownMenuItem(
                                      value: "IN_PROGRESS",
                                      child: Text('En Progreso')),
                                  DropdownMenuItem(
                                      value: "PENDING_INFORMATION",
                                      child: Text('Información pendiente')),
                                  DropdownMenuItem(
                                      value: "RESOLVED",
                                      child: Text('Resuelto')),
                                  DropdownMenuItem(
                                      value: "REJECTED",
                                      child: Text('Rechazado')),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    selectedStatus = value!;
                                  });
                                },
                                decoration: const InputDecoration(
                                  labelText: 'Estado del Ticket',
                                  border: OutlineInputBorder(),
                                  filled: true,
                                  fillColor: Color(0xFFF0F0F0),
                                ),
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'Escribe una respuesta',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.teal),
                              ),
                              const SizedBox(height: 10),
                              TextField(
                                controller: responseController,
                                maxLines: 4,
                                decoration: InputDecoration(
                                  labelText: 'Respuesta',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFFF0F0F0),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Center(
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    if (selectedStatus == 'null') {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                'Por favor seleccione un estado al cual cambiar.')),
                                      );
                                    }
                                    if (responseController.text.isNotEmpty) {
                                      try {
                                        await apiService.respondToTicket(
                                          widget.ticketToken,
                                          selectedStatus,
                                          responseController.text,
                                        );
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  'Respuesta enviada con éxito')),
                                        );
                                        Navigator.pop(context,
                                            true); // Regresar a la lista.
                                      } catch (e) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(content: Text('Error: $e')),
                                        );
                                      }
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                'El mensaje de respuesta no puede estar vacío')),
                                      );
                                    }
                                  },
                                  icon: const Icon(Icons.send),
                                  label: const Text('Responder Ticket'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color.fromARGB(255, 12, 110, 105),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () => showDeleteConfirmationDialog(),
                        icon: const Icon(Icons.delete),
                        label: const Text('Eliminar Ticket'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 245, 87, 83),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return const Center(
                child: Text('No se encontraron detalles del ticket'));
          }
        },
      ),
    );
  }
}
