import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/product_controller.dart';
import '../models/client.dart';
import '../models/product.dart';
import '../controller/client_controller.dart';

class ClientDetailsScreen extends StatelessWidget {
  final Rx<Client> client;
  final ProductController productController = Get.put(ProductController());
  final ClientController clientController = Get.find<ClientController>();

  ClientDetailsScreen({super.key, required Client client})
      : client = client.obs {
    // ✅ Store as observable
    productController.fetchProducts(client.id);
  }

  @override
  Widget build(BuildContext context) {
    // productController.fetchProducts(client.id);

    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(client.value.name)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showEditClientDialog(context), // ✏ Edit Button
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 📌 Client Details Card
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Client Details",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.phone, color: Colors.blue),
                        const SizedBox(width: 10),
                        Text(client.value.phone,
                            style: const TextStyle(fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.red),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(client.value.address,
                              style: const TextStyle(fontSize: 16)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
            // 📦 Product Details
            const Text("Products",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            Expanded(
              child: Obx(() => productController.products.isEmpty
                  ? const Center(child: Text("No products found."))
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: productController.products.length,
                      itemBuilder: (context, index) {
                        var product = productController.products[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            leading: Icon(Icons.devices,
                                color: Colors.blue.shade700, size: 36),
                            title: Text("🔖Model: ${product.model}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("📌 Serial: ${product.serialNumber}"),
                                Text("⚠ Issue: ${product.issue}"),
                                Text(
                                    "⚠ Registered Date: ${product.serviceDate.toLocal().toString().split(' ')[0]}"),
                                Text(
                                  "✅ Status: ${product.status}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: product.status == "Repaired"
                                        ? Colors.green
                                        : Colors.orange,
                                  ),
                                ),
                                if (product.status == "Repaired")
                                  Text(
                                      "💰 Repair Cost: ₹${product.repairCost ?? 0}"),
                                if (product.status == "Repaired" &&
                                    product.serviceClosureDate != null)
                                  Text(
                                    "📅 Closure Date: ${product.serviceClosureDate!.toLocal().toString().split(' ')[0]}",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                              ],
                            ),
                            trailing: LayoutBuilder(
                              builder: (context, constraints) {
                                bool isMobile = constraints.maxWidth <
                                    350; // Adjust breakpoint if needed
                                return isMobile
                                    ? Wrap(
                                        spacing:
                                            5, // Add spacing between buttons
                                        runSpacing:
                                            5, // Prevents overflow by wrapping buttons
                                        direction: Axis.vertical,
                                        children: [
                                          if (product.status == "Registered")
                                            ElevatedButton(
                                              onPressed: () =>
                                                  _showRepairDialog(
                                                      context, product),
                                              child: const Text(
                                                  "Mark as Repaired"),
                                            ),
                                          ElevatedButton(
                                            onPressed: () => _confirmDelete(
                                                context, product),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Colors.red.shade100,
                                            ),
                                            child: const Text("Delete"),
                                          ),
                                        ],
                                      )
                                    : Wrap(
                                        // Place buttons side by side for larger screens
                                        spacing: 8,
                                        runSpacing: 8,
                                        alignment: WrapAlignment.end,
                                        children: [
                                          if (product.status == "Registered")
                                            ElevatedButton(
                                              onPressed: () =>
                                                  _showRepairDialog(
                                                      context, product),
                                              child: const Text(
                                                  "Mark as Repaired"),
                                            ),
                                          ElevatedButton(
                                            onPressed: () => _confirmDelete(
                                                context, product),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Colors.red.shade100,
                                            ),
                                            child: const Text("Delete"),
                                          ),
                                        ],
                                      );
                              },
                            ),
                          ),
                        );
                      },
                    )),
            ),
          ],
        ),
      ),
    );
  }

  // 📌 Show Confirm Delete Dialog
  void _confirmDelete(BuildContext context, Product product) {
    Get.defaultDialog(
      title: "Delete Product?",
      middleText: "Are you sure you want to delete this product?",
      textConfirm: "Yes, Delete",
      textCancel: "Cancel",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        productController.deleteProduct(product);
        Get.back();
      },
    );
  }

  // 📌 Show Dialog to Enter Repair Cost
  void _showRepairDialog(BuildContext context, Product product) {
    TextEditingController costController = TextEditingController();

    Get.defaultDialog(
      title: "Enter Repair Cost",
      content: Padding(
        padding: const EdgeInsets.all(10),
        child: TextField(
          controller: costController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: "Repair Cost"),
        ),
      ),
      textConfirm: "Save",
      textCancel: "Cancel",
      confirmTextColor: Colors.white,
      buttonColor: Colors.green,
      onConfirm: () {
        if (costController.text.isNotEmpty) {
          double repairCost = double.parse(costController.text);
          productController.markAsRepaired(
              product, repairCost, client.value.phone);
          Get.back();
        }
      },
    );
  }

  // ✏ Show Edit Client Dialog
  void _showEditClientDialog(BuildContext context) {
    TextEditingController nameController =
        TextEditingController(text: client.value.name);
    TextEditingController phoneController =
        TextEditingController(text: client.value.phone);
    TextEditingController addressController =
        TextEditingController(text: client.value.address);

    Get.defaultDialog(
      title: "Edit Client Details",
      content: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: "Phone"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(labelText: "Address"),
            ),
          ],
        ),
      ),
      textConfirm: "Save",
      textCancel: "Cancel",
      confirmTextColor: Colors.white,
      buttonColor: Colors.blue,
      onConfirm: () {
        if (nameController.text.isNotEmpty &&
            phoneController.text.isNotEmpty &&
            addressController.text.isNotEmpty) {
          clientController.updateClientDetails(
              client.value.id,
              nameController.text,
              phoneController.text,
              addressController.text);
          client.value = client.value.copyWith(
              name: nameController.text,
              phone: phoneController.text,
              address: addressController.text); // ✅ Update UI instantly
          Get.back();
        }
      },
    );
  }
}
