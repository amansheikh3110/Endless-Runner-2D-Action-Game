import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import '../models/obstacle.dart';
import '../utils/score_manager.dart';
import 'start_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  // Game state
  bool _isPlaying = false;
  bool _isGameOver = false;
  int _score = 0;
  int _highScore = 0;
  bool _showHighScorePopup = false;
  
  // Character vertical physics (Chrome Dino style)
  // Using bottom positioning: bottom value = distance from bottom of screen
  // When grounded: bottom = trackHeight, when jumping: bottom increases (goes up)
  double _groundBottom = 0.0; // Ground position as bottom value (track top)
  double _characterBottom = 0.0; // Character bottom position (distance from screen bottom)
  double _vy = 0.0; // Vertical velocity (positive = moving up, negative = moving down)
  // Balanced physics for smooth, symmetric jump arc
  // Jump height = (jumpForce^2) / (2 * gravity)
  // Jump time = 2 * (jumpForce / gravity) frames
  final double _g = 0.85; // Reduced gravity for smoother, slower descent
  final double _jumpForce = 20.0; // Increased jump force for higher jump
  final double _maxJumpHeight = 300.0; // Maximum jump height - just below top boundary
  bool _isGrounded = true; // Grounded state
  
  // Obstacles
  List<Obstacle> _obstacles = [];
  final Random _random = Random();
  double _obstacleSpawnTimer = 0.0;
  double _nextSpawnInterval = 0.0; // Dynamic random interval
  // Spawn interval range - calculated to ensure safe gaps
  final double _minSpawnInterval = 1.5; // Minimum time between obstacles (seconds)
  final double _maxSpawnInterval = 4.0; // Maximum time between obstacles (seconds)
  
  // Track height and position
  final double _trackHeight = 60.0; // Thinner track
  final double _trackBottomOffset = 0.0; // Stick to bottom
  double _screenWidth = 0.0;
  double _screenHeight = 0.0;
  
  // Score system - continuous increment at 3 points per second
  double _scoreTimer = 0.0;
  final double _scoreIncrementRate = 3.0; // Points per second
  final double _scoreIncrementInterval = 1.0 / 3.0; // Every 0.33 seconds = 1 point
  
  // Speed scaling system (Chrome Dino style)
  final double _baseSpeed = 5.5; // Initial obstacle speed
  double _currentSpeed = 5.5; // Current speed (increases over time)
  final double _speedIncrement = 0.01; // Small increment per update
  final double _maxSpeed = 12.0; // Maximum speed cap
  double _gameTime = 0.0; // Track elapsed game time for speed scaling
  
  // Video initialization state
  bool _isVideoInitialized = false;
  
  // Video player
  VideoPlayerController? _videoController;
  
  // Game loop
  Timer? _gameTimer;
  
  @override
  void initState() {
    super.initState();
    _initializeGame();
    _loadHighScore();
  }

  Future<void> _initializeGame() async {
    // Lock orientation to landscape
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    
    // Initialize video player
    _videoController = VideoPlayerController.asset('lib/assets/bike_riding.mp4');
    await _videoController!.initialize();
    _videoController!.setLooping(true);
    _videoController!.play();
    
    // Update state to show video
    if (mounted) {
      setState(() {
        _isVideoInitialized = true;
      });
    }
    
    // Start game on tap
    _startGame();
  }

  Future<void> _loadHighScore() async {
    final highScore = await ScoreManager.getHighScore();
    setState(() {
      _highScore = highScore;
    });
  }


  void _startGame() {
    setState(() {
      _isPlaying = true;
      _isGameOver = false;
      _score = 0;
      _scoreTimer = 0.0;
      // Initialize player in grounded state
      _groundBottom = _trackBottomOffset + _trackHeight;
      _characterBottom = _groundBottom;
      _vy = 0.0;
      _isGrounded = true;
      _obstacles.clear();
      _obstacleSpawnTimer = 0.0;
      _nextSpawnInterval = _getRandomSpawnInterval(); // Initialize first spawn interval
      
      // Reset speed scaling system
      _currentSpeed = _baseSpeed;
      _gameTime = 0.0;
    });
    
    _gameTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (_isPlaying && !_isGameOver) {
        _updateGame();
      }
    });
  }

  /// Calculate a random spawn interval that ensures safe gaps between obstacles
  /// Takes into account current game speed to prevent obstacles from being too close
  double _getRandomSpawnInterval() {
    // Calculate minimum safe gap based on current speed
    // Jump duration: time to go up + time to come down
    // Up time = jumpForce / gravity, Down time = same (symmetric)
    final double jumpUpTime = _jumpForce / _g; // frames
    final double totalJumpTime = jumpUpTime * 2; // total jump duration in frames
    final double jumpTimeSeconds = totalJumpTime * 0.016; // Convert to seconds (60fps)
    
    // Distance obstacle travels during a jump
    // Obstacle width + distance traveled during jump + safety margin
    const double obstacleWidth = 60.0;
    final double distanceDuringJump = _currentSpeed * jumpTimeSeconds;
    const double safetyMargin = 100.0; // Extra safety margin in pixels
    final double minGapDistance = obstacleWidth + distanceDuringJump + safetyMargin;
    
    // Convert gap distance to time (seconds)
    // At current speed, how long does it take to travel minGapDistance?
    final double minTimeForGap = minGapDistance / _currentSpeed;
    
    // Ensure minimum spawn interval accounts for safe gap
    // Use the larger of: calculated safe gap or base minimum interval
    final double effectiveMinInterval = minTimeForGap > _minSpawnInterval 
        ? minTimeForGap 
        : _minSpawnInterval;
    
    // Generate random interval between effective minimum and maximum
    // Add some randomness for variety while maintaining safety
    final double randomFactor = _random.nextDouble(); // 0.0 to 1.0
    final double intervalRange = _maxSpawnInterval - effectiveMinInterval;
    final double randomInterval = effectiveMinInterval + (randomFactor * intervalRange);
    
    return randomInterval;
  }

  void _updateGame() {
    const double frameTime = 0.016; // ~16ms per frame at 60fps
    
    // Increment game time for speed scaling
    _gameTime += frameTime;
    
    // Gradually increase speed (Chrome Dino style)
    // Linear increase: speed += increment per frame
    // Capped at maximum speed for fairness
    if (_currentSpeed < _maxSpeed) {
      _currentSpeed += _speedIncrement * frameTime; // Scale increment by frame time
      if (_currentSpeed > _maxSpeed) {
        _currentSpeed = _maxSpeed;
      }
    }
    
    // Update character vertical physics (Chrome Dino style)
    // Apply gravity first (vy -= g, gravity pulls downward)
    _vy -= _g;
    
    // Then update vertical position (bottom += vy, positive vy moves up)
    _characterBottom += _vy;
    
    // Cap jump height to prevent going off screen
    // Calculate max height based on screen height - just below top boundary
    final maxBottom = _screenHeight - 20; // 20px margin from top
    if (_characterBottom > maxBottom) {
      _characterBottom = maxBottom;
      // Don't stop velocity abruptly - let it naturally reverse for smooth arc
      if (_vy > 0) {
        _vy = 0.0; // Only stop if still going up
      }
    }
    
    // Check collision with ground
    // When bottom <= groundBottom, snap to ground and reset state
    if (_characterBottom <= _groundBottom) {
      _characterBottom = _groundBottom;
      _vy = 0.0;
      _isGrounded = true;
    } else {
      // Character is in the air
      _isGrounded = false;
    }
    
    // Update obstacles using current speed (increases over time)
    _obstacleSpawnTimer += frameTime;
    if (_obstacleSpawnTimer >= _nextSpawnInterval) {
      // Safety check: ensure last obstacle is far enough away
      bool canSpawn = true;
      if (_obstacles.isNotEmpty) {
        final lastObstacle = _obstacles.last;
        // Calculate minimum safe distance
        final double jumpUpTime = _jumpForce / _g;
        final double totalJumpTime = jumpUpTime * 2;
        final double jumpTimeSeconds = totalJumpTime * 0.016;
        final double distanceDuringJump = _currentSpeed * jumpTimeSeconds;
        const double minSafeDistance = 60.0 + distanceDuringJump + 150.0; // obstacle width + jump distance + margin
        
        // Check if last obstacle is still too close to spawn point
        final double distanceFromSpawn = _screenWidth - lastObstacle.x;
        if (distanceFromSpawn < minSafeDistance) {
          canSpawn = false; // Wait a bit longer
        }
      }
      
      if (canSpawn) {
        _obstacleSpawnTimer = 0.0;
        _obstacles.add(Obstacle.generateRandom(_screenWidth));
        // Calculate next random spawn interval, ensuring safe gap
        _nextSpawnInterval = _getRandomSpawnInterval();
      }
    }
    
    for (var obstacle in _obstacles) {
      obstacle.update(_currentSpeed); // Use dynamic speed
    }
    _obstacles.removeWhere((obstacle) => obstacle.isOffScreen());
    
    // Check collisions
    _checkCollisions();
    
    // Update score - continuous increment at 3 points per second
    // Score increments: 0,1,2,3 in first second, 4,5,6 in next second, etc.
    _scoreTimer += frameTime;
    if (_scoreTimer >= _scoreIncrementInterval) {
      _score++;
      _scoreTimer = 0.0;
    }
    
    // Single setState call at the end for smoother performance
    setState(() {});
  }

  void _checkCollisions() {
    // Player hitbox - explicitly defined, separate from rendering
    const double characterWidth = 80.0;
    const double characterHeight = 100.0;
    const double characterX = 100.0;
    
    // Character base level is at _groundBottom (same as track top)
    final characterBaseLevel = _groundBottom;
    
    for (var obstacle in _obstacles) {
      // Character hitbox - precise boundaries using bottom positioning
      final characterLeft = characterX;
      final characterRight = characterX + characterWidth;
      final characterBottom = _characterBottom;
      final characterTop = characterBottom - characterHeight;
      
      // Obstacle hitbox - precise boundaries
      final obstacleLeft = obstacle.x;
      final obstacleRight = obstacle.x + obstacle.width;
      final obstacleBottom = characterBaseLevel;
      final obstacleTop = obstacleBottom - obstacle.height;
      
      // Precise collision detection
      final horizontalOverlap = characterRight > obstacleLeft && 
                                 characterLeft < obstacleRight;
      final verticalOverlap = characterBottom > obstacleTop && 
                              characterTop < obstacleBottom;
      
      if (horizontalOverlap && verticalOverlap) {
        _gameOver();
        return;
      }
    }
  }

  void _jump() {
    // Jump is allowed only if player is grounded - very responsive
    // Immediate response without waiting for setState
    if (_isGrounded && _isPlaying && !_isGameOver) {
      // Update immediately for instant response
      _vy = _jumpForce;
      _isGrounded = false;
      // Trigger setState for UI update
      setState(() {});
    }
    // No additional input affects the jump once initiated
  }

  Future<void> _gameOver() async {
    if (_isGameOver) return;
    
    setState(() {
      _isGameOver = true;
      _isPlaying = false;
    });
    
    _gameTimer?.cancel();
    
    // Check for new high score
    final isNewHigh = await ScoreManager.isNewHighScore(_score);
    if (isNewHigh) {
      await ScoreManager.saveHighScore(_score);
      setState(() {
        _highScore = _score;
        _showHighScorePopup = true;
      });
      
      // Hide popup after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _showHighScorePopup = false;
          });
        }
      });
    }
    
    // Show game over dialog after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _showGameOverDialog();
      }
    });
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: AlertDialog(
          backgroundColor: Colors.black.withOpacity(0.9),
          contentPadding: const EdgeInsets.all(24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'GAME OVER',
            style: TextStyle(
              fontFamily: 'GreatsRacing',
              color: Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 30, // Increased by 2
            ),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Score: $_score',
                style: const TextStyle(
                  fontFamily: 'GreatsRacing',
                  color: Colors.white,
                  fontSize: 26, // Increased by 2
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'High Score: $_highScore',
                style: const TextStyle(
                  fontFamily: 'GreatsRacing',
                  color: Colors.yellow,
                  fontSize: 22, // Increased by 2
                ),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const StartScreen()),
                );
              },
              child: const Text(
                'MENU',
                style: TextStyle(
                  fontFamily: 'GreatsRacing',
                  color: Colors.white,
                  fontSize: 20, // Increased by 2
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 20),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _startGame();
              },
              child: const Text(
                'PLAY AGAIN',
                style: TextStyle(
                  fontFamily: 'GreatsRacing',
                  color: Colors.green,
                  fontSize: 20, // Increased by 2
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _videoController?.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _screenWidth = MediaQuery.of(context).size.width;
    _screenHeight = MediaQuery.of(context).size.height;
    
    // Update groundBottom based on screen dimensions if not set
    if (_groundBottom == 0.0 || _groundBottom != _trackBottomOffset + _trackHeight) {
      _groundBottom = _trackBottomOffset + _trackHeight;
      // Initialize character position if game hasn't started
      if (!_isPlaying) {
        _characterBottom = _groundBottom;
      }
    }
    
    return Scaffold(
      body: GestureDetector(
        onTap: _jump,
        child: Stack(
          children: [
            // White background
            Container(
              color: Colors.white,
              width: double.infinity,
              height: double.infinity,
            ),
            
            // Track/ground
            _buildTrack(),
            
            // Obstacles
            ..._obstacles.map((obstacle) => _buildObstacle(obstacle)),
            
            // Character
            _buildCharacter(),
            
            // UI Overlay
            _buildUI(),
            
            // High score popup
            if (_showHighScorePopup) _buildHighScorePopup(),
            
            // Jump button
            _buildJumpButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTrack() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: _trackBottomOffset,
      height: _trackHeight,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.grey.shade800,
              Colors.grey.shade900,
            ],
          ),
        ),
        child: CustomPaint(
          painter: TrackPainter(),
        ),
      ),
    );
  }

  Widget _buildCharacter() {
    if (_videoController == null || !_isVideoInitialized) {
      // Show placeholder while loading
      return Positioned(
        left: 100,
        bottom: _characterBottom,
        child: Container(
          width: 80,
          height: 100,
          color: Colors.grey.withOpacity(0.3),
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }
    
    // Ensure video is playing
    if (_videoController!.value.isInitialized && !_videoController!.value.isPlaying) {
      _videoController!.play();
    }
    
    return Positioned(
      left: 100,
      bottom: _characterBottom, // Bottom position (increases when jumping up)
      child: Container(
        width: 80,
        height: 100,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.transparent),
        ),
        child: ClipRect(
          child: AspectRatio(
            aspectRatio: _videoController!.value.aspectRatio,
            child: VideoPlayer(_videoController!),
          ),
        ),
      ),
    );
  }

  Widget _buildObstacle(Obstacle obstacle) {
    // Position obstacles at the same level as the character (above the track)
    final characterBaseLevel = _trackBottomOffset + _trackHeight;
    
    return Positioned(
      left: obstacle.x,
      bottom: characterBaseLevel,
      child: SizedBox(
        width: obstacle.width,
        height: obstacle.height,
        child: Image.asset(
          obstacle.imagePath,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildUI() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Text(
                    'Score: $_score',
                    style: const TextStyle(
                      fontFamily: 'GreatsRacing',
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.yellow.withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                  child: Text(
                    'High: $_highScore',
                    style: TextStyle(
                      fontFamily: 'GreatsRacing',
                      color: Colors.yellow.shade300,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHighScorePopup() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.yellow.shade700,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              offset: const Offset(4, 4),
              blurRadius: 8,
            ),
          ],
        ),
        child: const Text(
          'NEW HIGH SCORE!',
          style: TextStyle(
            fontFamily: 'GreatsRacing',
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildJumpButton() {
    return Positioned(
      right: 30,
      bottom: 30,
      child: GestureDetector(
        onTap: _jump,
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.green.shade700,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 4,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                offset: const Offset(4, 4),
                blurRadius: 8,
              ),
            ],
          ),
          child: const Icon(
            Icons.arrow_upward,
            color: Colors.white,
            size: 40,
          ),
        ),
      ),
    );
  }
}

class TrackPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..strokeWidth = 2;
    
    // Draw track lines (center line and side markers)
    // Center line
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      paint,
    );
    
    // Side markers (dashed effect)
    final dashWidth = 20.0;
    final dashSpace = 10.0;
    double currentX = 0;
    
    while (currentX < size.width) {
      canvas.drawLine(
        Offset(currentX, size.height * 0.2),
        Offset(currentX + dashWidth, size.height * 0.2),
        paint,
      );
      canvas.drawLine(
        Offset(currentX, size.height * 0.8),
        Offset(currentX + dashWidth, size.height * 0.8),
        paint,
      );
      currentX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

