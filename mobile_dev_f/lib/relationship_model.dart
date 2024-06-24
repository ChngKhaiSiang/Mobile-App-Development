//lib/relationship_model.dart
class relationship_model{

  final String id1;
  final String id2;
  final String nickname;


  relationship_model({
    required this.id1,
    required this.id2,
    required this.nickname,
  });

  // Convert a RelationshipModel into a Map
  Map<String, dynamic> toMap() {
    return {
      'id1': id1,
      'id2': id2,
      'nickname': nickname,
    };
  }

  // Extract a RelationshipModel from a Map
  factory relationship_model.fromMap(Map<String, dynamic> map) {
    return relationship_model(
      id1 : map['id1'],
      id2 : map['id2'],
      nickname: map['nickname'],
    );
  }
}