import 'package:booking/data/main_location.dart';

class Agent {
  final String guid;
  final String name;
  final String car;
  final String phone;
  final MainLocation location;

  Agent({this.guid = "", this.name = "", this.car = "", this.phone = "", required this.location});

  factory Agent.fromJson(Map<String, dynamic> jsonData) {
    return Agent(
      guid: jsonData['guid'] ?? "",
      name: jsonData['name'] ?? "",
      car: jsonData['car'] ?? "",
      phone: jsonData['phone'] ?? "",
      location: MainLocation.fromJson(jsonData['location']),
    );
  }

  Map<String, dynamic> toJson() => {
        "id": guid,
        "name": name,
        "car": car,
        "phone": phone,
        "location": location,
      };

  @override
  String toString() {
    return toJson().toString();
  }
}
