import 'package:flame/components.dart';
import 'package:flame/game.dart';

enum TreeType { tree1, tree2, tree3, tree4 }

class Tree extends SpriteAnimationComponent with HasGameReference<FlameGame> {
  final TreeType treeType;
  
  Tree({
    required super.position,
    required this.treeType,
  }) : super(
    anchor: Anchor.bottomCenter,
  );

  @override
  Future<void> onLoad() async {
    super.onLoad();

    final String imagePath;
    final Vector2 textureSize;
    
    // Set image path and texture size based on tree type
    switch (treeType) {
      case TreeType.tree1:
        imagePath = 'free_pack/decorations/trees/tree1.png';
        textureSize = Vector2(192, 256); // tree1 is 256 pixels high
        break;
      case TreeType.tree2:
        imagePath = 'free_pack/decorations/trees/tree2.png';
        textureSize = Vector2(192, 256); // tree2 is 256 pixels high
        break;
      case TreeType.tree3:
        imagePath = 'free_pack/decorations/trees/tree3.png';
        textureSize = Vector2(192, 192); // tree3 is 192 pixels high
        break;
      case TreeType.tree4:
        imagePath = 'free_pack/decorations/trees/tree4.png';
        textureSize = Vector2(192, 192); // tree4 is 192 pixels high
        break;
    }

    // Load the tree image
    final image = await game.images.load(imagePath);
    
    // Create animation from the 8 frames
    animation = SpriteAnimation.fromFrameData(
      image,
      SpriteAnimationData.sequenced(
        amount: 8,
        stepTime: 0.15, // Slow gentle animation
        textureSize: textureSize,
        loop: true,
      ),
    );
    
    // Set component size to match texture size
    size = textureSize;

    priority = position.y.toInt();
  }
}

