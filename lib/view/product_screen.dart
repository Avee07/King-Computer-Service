import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/product_controller.dart';

class ProductScreen extends StatelessWidget {
  final String clientId;
  final ProductController productController = Get.put(ProductController());

  ProductScreen({super.key, required this.clientId});

  @override
  Widget build(BuildContext context) {
    productController.fetchProducts(clientId);

    return Scaffold(
      appBar: AppBar(title: const Text("Products")),
      body: Obx(() => ListView.builder(
            itemCount: productController.products.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(productController.products[index].model),
                subtitle: Text(
                    "Serial: ${productController.products[index].serialNumber}"),
              );
            },
          )),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          _showAddProductDialog(context);
        },
      ),
    );
  }

  // Show Add Product Dialog
  void _showAddProductDialog(BuildContext context) {
    TextEditingController serialController = TextEditingController();
    TextEditingController modelController = TextEditingController();
    TextEditingController issueController = TextEditingController();
    TextEditingController statusController = TextEditingController();

    Get.defaultDialog(
      title: "Add Product",
      content: Column(
        children: [
          TextField(
            controller: serialController,
            decoration: const InputDecoration(labelText: "Serial Number"),
          ),
          TextField(
            controller: modelController,
            decoration: const InputDecoration(labelText: "Model"),
          ),
          TextField(
            controller: issueController,
            decoration: const InputDecoration(labelText: "Issue"),
          ),
          TextField(
            controller: statusController,
            decoration: const InputDecoration(labelText: "Status"),
          ),
        ],
      ),
      textConfirm: "Save",
      textCancel: "Cancel",
      onConfirm: () {
        if (serialController.text.isNotEmpty &&
            modelController.text.isNotEmpty) {
          productController.addProduct(
            clientId,
            serialController.text,
            modelController.text,
            issueController.text,
            statusController.text,
          );
          Get.back(); // Close dialog
        }
      },
    );
  }
}
