import 'package:flutter/material.dart';

class RectangleImageButton extends StatelessWidget {
  final double size;
  final IconData iconData;
  final Function onPressed;

  RectangleImageButton(this.size, this.iconData, this.onPressed);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      child: RawMaterialButton(
        onPressed: onPressed,
        child: Icon(
          iconData,
          color: Colors.black,
          size: size / 1.5,
        ),
        fillColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            width: 1,
            color: Colors.grey[700],
          ),
        ),
      ),
    );
  }
}
