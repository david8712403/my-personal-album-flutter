import 'dart:convert';

class Media {
  final int? id;
  final String name;
  final String path;
  final String type;
  final String previewImageUrl;
  final String originalContentUrl;

  Media({
    this.id,
    required this.name,
    required this.path,
    required this.type,
    required this.previewImageUrl,
    required this.originalContentUrl,
  });

  Media copyWith({
    int? id,
    String? name,
    String? path,
    String? type,
    String? previewImageUrl,
    String? originalContentUrl,
  }) {
    return Media(
      id: id ?? this.id,
      name: name ?? this.name,
      path: path ?? this.path,
      type: type ?? this.type,
      previewImageUrl: previewImageUrl ?? this.previewImageUrl,
      originalContentUrl: originalContentUrl ?? this.originalContentUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'path': path,
      'type': type,
      'previewImageUrl': previewImageUrl,
      'originalContentUrl': originalContentUrl,
    };
  }

  factory Media.fromMap(Map<String, dynamic> map) {
    return Media(
      id: map['id']?.toInt(),
      name: map['name'] ?? '',
      path: map['path'] ?? '',
      type: map['type'] ?? '',
      previewImageUrl: map['previewImageUrl'] ?? '',
      originalContentUrl: map['originalContentUrl'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Media.fromJson(String source) => Media.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Media(id: $id, name: $name, path: $path, type: $type, previewImageUrl: $previewImageUrl, originalContentUrl: $originalContentUrl)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Media &&
        other.id == id &&
        other.name == name &&
        other.path == path &&
        other.type == type &&
        other.previewImageUrl == previewImageUrl &&
        other.originalContentUrl == originalContentUrl;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        path.hashCode ^
        type.hashCode ^
        previewImageUrl.hashCode ^
        originalContentUrl.hashCode;
  }
}
