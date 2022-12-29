import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AutoMediaService {
  static const host = "am.yanlin.tw";
  static Future<List<AutoMediaMessageItem>> getMediaMessage(String url) async {
    final encodeUrl = Uri.encodeFull(url);
    final response =
        await http.get(Uri.https(host, "/v2/mediaGetter", {"url": encodeUrl}));
    if (response.statusCode == 200) {
      return MediaGetterResponse.fromMap(jsonDecode(response.body)).messages;
    } else {
      throw Exception('Failed to load album');
    }
  }
}

class MediaGetterResponse {
  final List<AutoMediaMessageItem> messages;
  MediaGetterResponse({
    required this.messages,
  });

  MediaGetterResponse copyWith({
    List<AutoMediaMessageItem>? messages,
  }) {
    return MediaGetterResponse(
      messages: messages ?? this.messages,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'messages': messages.map((x) => x.toMap()).toList(),
    };
  }

  factory MediaGetterResponse.fromMap(Map<String, dynamic> map) {
    return MediaGetterResponse(
      messages: List<AutoMediaMessageItem>.from(
          map['messages']?.map((x) => AutoMediaMessageItem.fromMap(x))),
    );
  }

  String toJson() => json.encode(toMap());

  factory MediaGetterResponse.fromJson(String source) =>
      MediaGetterResponse.fromMap(json.decode(source));

  @override
  String toString() => 'MediaGetterResponse(messages: $messages)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MediaGetterResponse && listEquals(other.messages, messages);
  }

  @override
  int get hashCode => messages.hashCode;
}

class AutoMediaMessageItem {
  final String type;
  final String previewImageUrl;
  final String originalContentUrl;
  AutoMediaMessageItem({
    required this.type,
    required this.previewImageUrl,
    required this.originalContentUrl,
  });

  AutoMediaMessageItem copyWith({
    String? type,
    String? previewImageUrl,
    String? originalContentUrl,
  }) {
    return AutoMediaMessageItem(
      type: type ?? this.type,
      previewImageUrl: previewImageUrl ?? this.previewImageUrl,
      originalContentUrl: originalContentUrl ?? this.originalContentUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'previewImageUrl': previewImageUrl,
      'originalContentUrl': originalContentUrl,
    };
  }

  factory AutoMediaMessageItem.fromMap(Map<String, dynamic> map) {
    return AutoMediaMessageItem(
      type: map['type'] ?? '',
      previewImageUrl: map['previewImageUrl'] ?? '',
      originalContentUrl: map['originalContentUrl'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory AutoMediaMessageItem.fromJson(String source) =>
      AutoMediaMessageItem.fromMap(json.decode(source));

  @override
  String toString() =>
      'AutoMediaMessageItem(type: $type, previewImageUrl: $previewImageUrl, originalContentUrl: $originalContentUrl)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AutoMediaMessageItem &&
        other.type == type &&
        other.previewImageUrl == previewImageUrl &&
        other.originalContentUrl == originalContentUrl;
  }

  @override
  int get hashCode =>
      type.hashCode ^ previewImageUrl.hashCode ^ originalContentUrl.hashCode;
}
