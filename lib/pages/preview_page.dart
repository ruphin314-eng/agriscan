import 'dart:io';
import 'package:flutter/material.dart';

class PreviewPage extends StatelessWidget {
  final String imagePath;

  const PreviewPage({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Aperçu de l'image")),
      body: Center(child: Image.file(File(imagePath), fit: BoxFit.contain)),
    );
  }
}
