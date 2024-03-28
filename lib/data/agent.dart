import 'package:google_maps_flutter/google_maps_flutter.dart';

class Agent {
  final String guid;
  final String name;
  final String car;
  final String phone;
  final double lt;
  final double ln;

  Agent({this.guid = "", this.name = "", this.car = "", this.phone = "", required this.lt, required this.ln});

  factory Agent.fromJson(Map<String, dynamic> jsonData) {
    return Agent(
      guid: jsonData['guid'] ?? "",
      name: jsonData['name'] ?? "",
      car: jsonData['car'] ?? "",
      phone: jsonData['phone'] ?? "",
      lt: double.tryParse(jsonData['lt'].toString()) ?? 0,
      ln: double.tryParse(jsonData['ln'].toString()) ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        "id": guid,
        "name": name,
        "car": car,
        "phone": phone,
        "lt": lt,
        "ln": ln,
      };

  @override
  String toString() {
    return toJson().toString();
  }

  LatLng get location {
    return LatLng(lt, ln);
  }
}
