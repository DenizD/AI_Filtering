import 'package:flutter/material.dart';

class EffectComponent extends StatelessWidget {
  final double size;
  final String imageFile;
  final Color borderColor;
  final String description;
  final Function onTap;

  EffectComponent(this.size, this.imageFile, this.borderColor, this.description,
      this.onTap);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: size - 20.0,
            height: size - 20.0,
            decoration: BoxDecoration(
              color: Color(0xff7c94b6),
              image: DecorationImage(
                image: AssetImage(imageFile),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
              border: Border.all(
                color: borderColor,
                width: 2.0,
              ),
            ),
          ),
          Text(
            description,
            style: TextStyle(fontSize: 10.0),
          ),
        ],
      ),
    );
  }
}
