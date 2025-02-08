import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/client_controller.dart';
import 'client_details_screen.dart';

class ClientScreen extends StatelessWidget {
  final ClientController clientController = Get.put(ClientController());

  ClientScreen({super.key}) {
    clientController.fetchClients(); // ✅ Fetch clients when screen opens
  }

  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Clients")),
      body: Column(
        children: [
          // 🔍 Search Bar
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: "Search by Name or Serial Number",
                prefixIcon: const Icon(Icons.search),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onChanged: (query) {
                clientController.searchClients(query);
              },
            ),
          ),

          // 📋 Client List
          Expanded(
            child: Obx(() => clientController.filteredClients.isEmpty
                ? const Center(
                    child:
                        CircularProgressIndicator()) // 🛠 Show loading if empty
                : ListView.builder(
                    itemCount: clientController.filteredClients.length,
                    itemBuilder: (context, index) {
                      var client = clientController.filteredClients[index];
                      return ListTile(
                        title: Text(client.name),
                        subtitle: Text(client.phone),
                        onTap: () {
                          Get.to(() => ClientDetailsScreen(client: client));
                        },
                      );
                    },
                  )),
          ),
        ],
      ),
    );
  }
}
