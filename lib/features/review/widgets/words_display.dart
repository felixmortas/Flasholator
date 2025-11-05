import 'package:flutter/material.dart';
import 'package:flasholator/config/constants.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flasholator/style/app_colors.dart';

class WordsDisplay extends StatelessWidget {
  final String questionLang;
  final String questionText;
  final String responseLang;
  final String responseText;
  final bool isResponseHidden;
  final VoidCallback onDisplayAnswer;
  final bool isCardConsumed;

  const WordsDisplay({
    Key? key,
    required this.questionLang,
    required this.questionText,
    required this.responseLang,
    required this.responseText,
    required this.isResponseHidden,
    required this.onDisplayAnswer,
    required this.isCardConsumed,
  }) : super(key: key);

  Widget _buildPostItCard({
    required String langTag,
    required String text,
    required double width,
    required double height,
    required bool showText,
    required Color postItColor,
    required double rotation,
    Widget? overlayIcon,
  }) {
    return Transform(
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..rotateX(-0.015)
        ..rotateZ(rotation),
      alignment: Alignment.bottomRight,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: postItColor,
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 2,
              offset: const Offset(0, 1),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 4,
              offset: const Offset(2, 3),
              spreadRadius: -1,
            ),
          ],
        ),
        child: Column(
          children: [
            // Bande adhésive en haut
            Container(
              height: 12,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    _getDarkerShade(postItColor, 0.4),
                    _getDarkerShade(postItColor, 0.25),
                    _getDarkerShade(postItColor, 0.1),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: _getDarkerShade(postItColor, 0.15),
                    blurRadius: 1,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
            // Contenu du post-it
            Expanded(
              child: Stack(
                children: [
                  // Tag de langue en haut à gauche
                  Positioned(
                    top: 8.0,
                    left: 12.0,
                    child: Text(
                      langTag,
                      style: GoogleFonts.poppins(
                        fontSize: 11.0,
                        fontWeight: FontWeight.w300,
                        color: Colors.grey.shade500,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  // Texte centré
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 16.0,
                      ),
                      child: showText
                          ? Text(
                              text,
                              style: GoogleFonts.poppins(
                                fontSize: 22.0,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade800,
                                letterSpacing: 0.3,
                                height: 1.3,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                            )
                          : const SizedBox.shrink(),
                    ),
                  ),
                  // Icône overlay si fournie
                  if (overlayIcon != null)
                    Center(child: overlayIcon),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getDarkerShade(Color color, double opacity) {
    final hsl = HSLColor.fromColor(color);
    final darkened = hsl.withLightness((hsl.lightness - 0.15).clamp(0.0, 1.0));
    return darkened.toColor().withOpacity(opacity);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth / GOLDEN_NUMBER;
    final cardHeight = cardWidth / 1.4;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Carte question (post-it bleu/cyan)
        Center(
          child: _buildPostItCard(
            langTag: questionLang,
            text: questionText,
            width: cardWidth,
            height: cardHeight,
            showText: true,
            postItColor: AppColors.postit, // Bleu clair post-it
            rotation: -0.008, // Légère rotation à gauche
          ),
        ),

        const SizedBox(height: 16.0),
        Container(height: 1.0, color: Colors.grey.shade300),
        const SizedBox(height: 16.0),

        // Carte réponse (post-it rose/pêche)
        Center(
          child: SizedBox(
            width: cardWidth,
            height: cardHeight,
            child: Draggable<int>(
              data: 1,
              maxSimultaneousDrags: isResponseHidden ? 0 : 1,
              feedback: Material(
                color: Colors.transparent,
                child: _buildPostItCard(
                  langTag: responseLang,
                  text: responseText,
                  width: cardWidth,
                  height: cardHeight,
                  showText: true,
                  postItColor: AppColors.postit, // Rose/pêche
                  rotation: 0.012, // Rotation à droite
                ),
              ),
              childWhenDragging: const SizedBox.shrink(),
              child: isCardConsumed
                  ? const SizedBox.shrink()
                  : GestureDetector(
                      onTap: isResponseHidden ? onDisplayAnswer : null,
                      child: _buildPostItCard(
                        langTag: responseLang,
                        text: responseText,
                        width: cardWidth,
                        height: cardHeight,
                        showText: !isResponseHidden,
                        postItColor: AppColors.postit, // Rose/pêche
                        rotation: 0.012,
                        overlayIcon: isResponseHidden ? const _PulsingTouchIcon() : null,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PulsingTouchIcon extends StatefulWidget {
  const _PulsingTouchIcon();

  @override
  State<_PulsingTouchIcon> createState() => _PulsingTouchIconState();
}

class _PulsingTouchIconState extends State<_PulsingTouchIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 809),
      vsync: this,
    )..repeat(reverse: true);
    
    _animation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: Icon(
            Icons.touch_app,
            size: 48.0,
            color: Colors.grey.shade600,
          ),
        );
      },
    );
  }
}