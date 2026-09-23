/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:claimdesk_server/src/generated/protocol.dart' as _ii1g677k;
import 'package:serverpod/serverpod.dart' as _is;

abstract class ItemAttributes
    implements _is.SerializableModel, _is.ProtocolSerialization {
  ItemAttributes._({
    required this.category,
    this.categoryConfidence,
    required this.colours,
    this.brand,
    this.material,
    required this.marks,
    required this.description,
    bool? containsPersonalData,
    required this.personalDataKinds,
    this.imageQuality,
    required this.keywords,
    this.language,
    required this.source,
    this.modelId,
    this.promptVersion,
  }) : containsPersonalData = containsPersonalData ?? false;

  factory ItemAttributes({
    required String category,
    double? categoryConfidence,
    required List<String> colours,
    String? brand,
    String? material,
    required List<String> marks,
    required String description,
    bool? containsPersonalData,
    required List<String> personalDataKinds,
    String? imageQuality,
    required List<String> keywords,
    String? language,
    required String source,
    String? modelId,
    String? promptVersion,
  }) = _ItemAttributesImpl;

  factory ItemAttributes.fromJson(Map<String, dynamic> jsonSerialization) {
    return ItemAttributes(
      category: jsonSerialization['category'] as String,
      categoryConfidence: (jsonSerialization['categoryConfidence'] as num?)
          ?.toDouble(),
      colours: _ii1g677k.Protocol().deserialize<List<String>>(
        jsonSerialization['colours'],
      ),
      brand: jsonSerialization['brand'] as String?,
      material: jsonSerialization['material'] as String?,
      marks: _ii1g677k.Protocol().deserialize<List<String>>(
        jsonSerialization['marks'],
      ),
      description: jsonSerialization['description'] as String,
      containsPersonalData: jsonSerialization['containsPersonalData'] == null
          ? null
          : _is.BoolJsonExtension.fromJson(
              jsonSerialization['containsPersonalData'],
            ),
      personalDataKinds: _ii1g677k.Protocol().deserialize<List<String>>(
        jsonSerialization['personalDataKinds'],
      ),
      imageQuality: jsonSerialization['imageQuality'] as String?,
      keywords: _ii1g677k.Protocol().deserialize<List<String>>(
        jsonSerialization['keywords'],
      ),
      language: jsonSerialization['language'] as String?,
      source: jsonSerialization['source'] as String,
      modelId: jsonSerialization['modelId'] as String?,
      promptVersion: jsonSerialization['promptVersion'] as String?,
    );
  }

  String category;

  double? categoryConfidence;

  List<String> colours;

  String? brand;

  String? material;

  List<String> marks;

  String description;

  bool containsPersonalData;

  List<String> personalDataKinds;

  String? imageQuality;

  List<String> keywords;

  String? language;

  String source;

  String? modelId;

  String? promptVersion;

  /// Returns a shallow copy of this [ItemAttributes]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  ItemAttributes copyWith({
    String? category,
    double? categoryConfidence,
    List<String>? colours,
    String? brand,
    String? material,
    List<String>? marks,
    String? description,
    bool? containsPersonalData,
    List<String>? personalDataKinds,
    String? imageQuality,
    List<String>? keywords,
    String? language,
    String? source,
    String? modelId,
    String? promptVersion,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ItemAttributes',
      'category': category,
      if (categoryConfidence != null) 'categoryConfidence': categoryConfidence,
      'colours': colours.toJson(),
      if (brand != null) 'brand': brand,
      if (material != null) 'material': material,
      'marks': marks.toJson(),
      'description': description,
      'containsPersonalData': containsPersonalData,
      'personalDataKinds': personalDataKinds.toJson(),
      if (imageQuality != null) 'imageQuality': imageQuality,
      'keywords': keywords.toJson(),
      if (language != null) 'language': language,
      'source': source,
      if (modelId != null) 'modelId': modelId,
      if (promptVersion != null) 'promptVersion': promptVersion,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ItemAttributes',
      'category': category,
      if (categoryConfidence != null) 'categoryConfidence': categoryConfidence,
      'colours': colours.toJson(),
      if (brand != null) 'brand': brand,
      if (material != null) 'material': material,
      'marks': marks.toJson(),
      'description': description,
      'containsPersonalData': containsPersonalData,
      'personalDataKinds': personalDataKinds.toJson(),
      if (imageQuality != null) 'imageQuality': imageQuality,
      'keywords': keywords.toJson(),
      if (language != null) 'language': language,
      'source': source,
      if (modelId != null) 'modelId': modelId,
      if (promptVersion != null) 'promptVersion': promptVersion,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ItemAttributesImpl extends ItemAttributes {
  _ItemAttributesImpl({
    required String category,
    double? categoryConfidence,
    required List<String> colours,
    String? brand,
    String? material,
    required List<String> marks,
    required String description,
    bool? containsPersonalData,
    required List<String> personalDataKinds,
    String? imageQuality,
    required List<String> keywords,
    String? language,
    required String source,
    String? modelId,
    String? promptVersion,
  }) : super._(
         category: category,
         categoryConfidence: categoryConfidence,
         colours: colours,
         brand: brand,
         material: material,
         marks: marks,
         description: description,
         containsPersonalData: containsPersonalData,
         personalDataKinds: personalDataKinds,
         imageQuality: imageQuality,
         keywords: keywords,
         language: language,
         source: source,
         modelId: modelId,
         promptVersion: promptVersion,
       );

  /// Returns a shallow copy of this [ItemAttributes]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  ItemAttributes copyWith({
    String? category,
    Object? categoryConfidence = _Undefined,
    List<String>? colours,
    Object? brand = _Undefined,
    Object? material = _Undefined,
    List<String>? marks,
    String? description,
    bool? containsPersonalData,
    List<String>? personalDataKinds,
    Object? imageQuality = _Undefined,
    List<String>? keywords,
    Object? language = _Undefined,
    String? source,
    Object? modelId = _Undefined,
    Object? promptVersion = _Undefined,
  }) {
    return ItemAttributes(
      category: category ?? this.category,
      categoryConfidence: categoryConfidence is double?
          ? categoryConfidence
          : this.categoryConfidence,
      colours: colours ?? this.colours.map((e0) => e0).toList(),
      brand: brand is String? ? brand : this.brand,
      material: material is String? ? material : this.material,
      marks: marks ?? this.marks.map((e0) => e0).toList(),
      description: description ?? this.description,
      containsPersonalData: containsPersonalData ?? this.containsPersonalData,
      personalDataKinds:
          personalDataKinds ?? this.personalDataKinds.map((e0) => e0).toList(),
      imageQuality: imageQuality is String? ? imageQuality : this.imageQuality,
      keywords: keywords ?? this.keywords.map((e0) => e0).toList(),
      language: language is String? ? language : this.language,
      source: source ?? this.source,
      modelId: modelId is String? ? modelId : this.modelId,
      promptVersion: promptVersion is String?
          ? promptVersion
          : this.promptVersion,
    );
  }
}
