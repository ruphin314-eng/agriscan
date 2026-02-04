import 'package:flutter/material.dart';
import '../models/maladie.dart';

class DetailMaladie extends StatelessWidget {
  final Maladie maladie;

  const DetailMaladie({Key? key, required this.maladie}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(maladie.nom),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              maladie.image,
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Description",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(maladie.description),

                  const SizedBox(height: 24),
                  const Text(
                    "Prévention et traitement",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(maladie.solution),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
