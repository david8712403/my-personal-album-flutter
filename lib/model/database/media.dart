import 'dart:convert';

class Media {
  final int? id;
  final String created;
  final String name;
  final String? description;
  final String type;
  final String previewImageUrl;
  final String? previewImagePath;
  final String previewTaskId;
  final String originalContentUrl;
  final String? originalContentPath;
  final String originalTaskId;
  Media({
    this.id,
    required this.created,
    required this.name,
    this.description,
    required this.type,
    required this.previewImageUrl,
    this.previewImagePath,
    required this.previewTaskId,
    required this.originalContentUrl,
    this.originalContentPath,
    required this.originalTaskId,
  });

  Media copyWith({
    int? id,
    String? created,
    String? name,
    String? description,
    String? type,
    String? previewImageUrl,
    String? previewImagePath,
    String? previewTaskId,
    String? originalContentUrl,
    String? originalContentPath,
    String? originalTaskId,
  }) {
    return Media(
      id: id ?? this.id,
      created: created ?? this.created,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      previewImageUrl: previewImageUrl ?? this.previewImageUrl,
      previewImagePath: previewImagePath ?? this.previewImagePath,
      previewTaskId: previewTaskId ?? this.previewTaskId,
      originalContentUrl: originalContentUrl ?? this.originalContentUrl,
      originalContentPath: originalContentPath ?? this.originalContentPath,
      originalTaskId: originalTaskId ?? this.originalTaskId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'created': created,
      'name': name,
      'description': description,
      'type': type,
      'previewImageUrl': previewImageUrl,
      'previewImagePath': previewImagePath,
      'previewTaskId': previewTaskId,
      'originalContentUrl': originalContentUrl,
      'originalContentPath': originalContentPath,
      'originalTaskId': originalTaskId,
    };
  }

  factory Media.fromMap(Map<String, dynamic> map) {
    return Media(
      id: map['id']?.toInt(),
      created: map['created'] ?? '',
      name: map['name'] ?? '',
      description: map['description'],
      type: map['type'] ?? '',
      previewImageUrl: map['previewImageUrl'] ?? '',
      previewImagePath: map['previewImagePath'],
      previewTaskId: map['previewTaskId'] ?? '',
      originalContentUrl: map['originalContentUrl'] ?? '',
      originalContentPath: map['originalContentPath'],
      originalTaskId: map['originalTaskId'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Media.fromJson(String source) => Media.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Media(id: $id, created: $created, name: $name, description: $description, type: $type, previewImageUrl: $previewImageUrl, previewImagePath: $previewImagePath, previewTaskId: $previewTaskId, originalContentUrl: $originalContentUrl, originalContentPath: $originalContentPath, originalTaskId: $originalTaskId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Media &&
        other.id == id &&
        other.created == created &&
        other.name == name &&
        other.description == description &&
        other.type == type &&
        other.previewImageUrl == previewImageUrl &&
        other.previewImagePath == previewImagePath &&
        other.previewTaskId == previewTaskId &&
        other.originalContentUrl == originalContentUrl &&
        other.originalContentPath == originalContentPath &&
        other.originalTaskId == originalTaskId;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        created.hashCode ^
        name.hashCode ^
        description.hashCode ^
        type.hashCode ^
        previewImageUrl.hashCode ^
        previewImagePath.hashCode ^
        previewTaskId.hashCode ^
        originalContentUrl.hashCode ^
        originalContentPath.hashCode ^
        originalTaskId.hashCode;
  }
}
