import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/product_controller.dart';
import '../models/client.dart';
import '../models/product.dart';

class ClientDetailsScreen extends StatelessWidget {
  final Client client;
  final ProductController productController = Get.put(ProductController());

  ClientDetailsScreen({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    productController.fetchProducts(client.id);

    return Scaffold(
      appBar: AppBar(title: Text(client.name)),
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
                        Text(client.phone,
                            style: const TextStyle(fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.red),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(client.address,
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
            Obx(() => productController.products.isEmpty
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
                          title: Text("🔖 ${product.model}",
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("📌 Serial: ${product.serialNumber}"),
                              Text("⚠ Issue: ${product.issue}"),
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
                            ],
                          ),
                          trailing: product.status == "Registered"
                              ? ElevatedButton(
                                  onPressed: () =>
                                      _showRepairDialog(context, product),
                                  child: const Text("Mark as Repaired"),
                                )
                              : null,
                        ),
                      );
                    },
                  )),
          ],
        ),
      ),
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
          productController.markAsRepaired(product, repairCost, client.phone);
          Get.back();
        }
      },
    );
  }
}
