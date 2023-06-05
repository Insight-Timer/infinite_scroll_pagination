/// Summarized information of a character.
class CharacterSummary {
  CharacterSummary({
    required this.id,
    required this.name,
    required this.pictureUrl,
  });

  factory CharacterSummary.fromJson(Map<String, dynamic> json) => CharacterSummary(
        id: json['id'],
        name: json['id'],
        pictureUrl: json['url'],
      );

  final String id;
  final String name;
  final String pictureUrl;
}
