import 'package:morpho/i18n/strings.g.dart';

/// The six plant personalities a habit can grow into.
///
/// Chosen at creation time; drives the CustomPainter rendering path and gives
/// each habit a distinct visual identity in the garden grid.
enum PlantType {
  fern('🌿'),
  cactus('🌵'),
  orchid('🌸'),
  bonsai('🌳'),
  sunflower('🌻'),
  bamboo('🎋');

  const PlantType(this.emoji);

  final String emoji;

  String get label {
    switch (this) {
      case fern:
        return t.plantType.fern;
      case cactus:
        return t.plantType.cactus;
      case orchid:
        return t.plantType.orchid;
      case bonsai:
        return t.plantType.bonsai;
      case sunflower:
        return t.plantType.sunflower;
      case bamboo:
        return t.plantType.bamboo;
    }
  }
}
