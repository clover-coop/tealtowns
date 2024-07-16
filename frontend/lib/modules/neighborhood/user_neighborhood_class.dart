import './neighborhood_class.dart';
import '../../common/parse_service.dart';
import '../user_auth/user_class.dart';

class UserNeighborhoodClass {
  ParseService _parseService = ParseService();

  String id = '', userId = '', username = '', neighborhoodUName = '', status = '', vision = '', createdAt = '';
  List<String> roles = [], motivations = [];
  NeighborhoodClass neighborhood = NeighborhoodClass.fromJson({});
  UserClass user = UserClass.fromJson({});

  UserNeighborhoodClass(this.id, this.userId, this.username, this.neighborhoodUName, this.status, this.vision,
    this.createdAt, this.roles,
    this.motivations, this.neighborhood, this.user);

  UserNeighborhoodClass.fromJson(Map<String, dynamic> json) {
    this.id = json.containsKey('_id') ? json['_id'] : json.containsKey('id') ? json['id'] : '';
    this.userId = json['userId'] ?? '';
    this.username = json['username'] ?? '';
    this.neighborhoodUName = json['neighborhoodUName'] ?? '';
    this.status = json['status'] ?? '';
    this.vision = json['vision'] ?? '';
    this.createdAt = json['createdAt'] ?? '';
    this.roles = json.containsKey('roles') ? _parseService.parseListString(json['roles']) : [];
    this.motivations = json.containsKey('motivations') ? _parseService.parseListString(json['motivations']) : [];
    this.neighborhood = NeighborhoodClass.fromJson(json['neighborhood'] ?? {});
    this.user = UserClass.fromJson(json['user'] ?? {});
  }

  Map<String, dynamic> toJson() =>
    {
      '_id': id,
      'userId': userId,
      'username': username,
      'neighborhoodUName': neighborhoodUName,
      'status': status,
      'vision': vision,
      'createdAt': createdAt,
      'roles': roles,
      'motivations': motivations,
    };
  
  static List<Map<String, dynamic>> toJsonList(List<UserNeighborhoodClass> items) {
    List<Map<String, dynamic>> data = [];
    for (var i = 0; i < items.length; i++) {
      Map<String, dynamic> item = items[i].toJson();
      item['neighborhood'] = items[i].neighborhood.toJson();
      item['user'] = items[i].user.toJson();
      data.add(item);
    }
    return data;
  }
  
  static List<UserNeighborhoodClass> parseList(List<dynamic> itemsRaw) {
    List<UserNeighborhoodClass> items = [];
    if (itemsRaw != null) {
      for (var item in itemsRaw) {
        items.add(UserNeighborhoodClass.fromJson(item));
      }
    }
    return items;
  }

}
