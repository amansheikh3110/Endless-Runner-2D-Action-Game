import 'dart:math';

class Obstacle {
  double x;
  final String imagePath;
  final double width;
  final double height;

  Obstacle({
    required this.x,
    required this.imagePath,
    required this.width,
    required this.height,
  });

  static Obstacle generateRandom(double screenWidth) {
    final random = Random();
    
    // Randomly select one of the 3 obstacle images
    final obstacleImages = [
      'lib/assets/obstacle_1-removebg-preview.png',
      'lib/assets/obstacle_2-removebg-preview.png',
      'lib/assets/obstacle_3-removebg-preview.png',
    ];
    final selectedImage = obstacleImages[random.nextInt(obstacleImages.length)];
    
    // Default dimensions - scaled to fit game
    double width = 60.0;
    double height = 75.0;
    
    return Obstacle(
      x: screenWidth,
      imagePath: selectedImage,
      width: width,
      height: height,
    );
  }

  void update(double speed) {
    x -= speed;
  }

  bool isOffScreen() {
    return x + width < 0;
  }
}

