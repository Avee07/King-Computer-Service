import 'package:client_details_app/models/client.dart';
import 'package:client_details_app/models/product.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<void> addClient(Client client) async {
    await _db.collection("clients").doc(client.id).set(client.toJson());
  }

  static Future<List<Client>> getClients() async {
    var snapshot = await _db.collection("clients").get();
    return snapshot.docs.map((doc) => Client.fromJson(doc.data())).toList();
  }

  static Future<void> addProduct(Product product) async {
    await _db.collection("products").doc(product.id).set(product.toJson());
  }

  static Future<List<Product>> getProducts(String clientId) async {
    var snapshot = await _db
        .collection("products")
        .where('clientId', isEqualTo: clientId)
        .get();
    return snapshot.docs.map((doc) => Product.fromJson(doc.data())).toList();
  }
}
