import 'package:flutter/material.dart';
import 'package:flasholator/config/constants.dart';

class BottomEmptyReviewOverlay extends StatelessWidget {
  final String content;

  const BottomEmptyReviewOverlay({Key? key, required this.content})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Align(
      alignment: Alignment.bottomCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          // minHeight pour qu’il soit visible
          minHeight: 100,
          // maxHeight = 32% de l’écran
          maxHeight: screenHeight * 0.35,
        ),
        child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
              top: Radius.circular(25 * GOLDEN_NUMBER)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 5,
              margin: EdgeInsets.only(top: 8 * GOLDEN_NUMBER),
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            SizedBox(height: 16 * GOLDEN_NUMBER),
            // Contenu
            Expanded(
                child: SingleChildScrollView(
                  padding:
                      EdgeInsets.symmetric(horizontal: 20 * GOLDEN_NUMBER)
                          .copyWith(bottom: 20 * GOLDEN_NUMBER),
                  child: Text(
                    content,
                    style: TextStyle(
                      fontSize: 16 * GOLDEN_NUMBER,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
      ),
    );
  }
}
