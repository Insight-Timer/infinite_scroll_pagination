import 'package:breaking_bapp/character_summary.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CharacterGridItem extends StatelessWidget {
  const CharacterGridItem({
    required this.character,
    required this.index,
    Key? key,
  }) : super(key: key);
  final CharacterSummary character;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CachedNetworkImage(
          imageUrl: character.pictureUrl,
        ),
        Text(index.toString())
      ],
    );
  }
}
