import 'dart:io';
import 'package:flutter/material.dart';

class ImportTransactionPage extends StatelessWidget {
  final String imagePath;

  const ImportTransactionPage({
    super.key,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Import Transaksi'),
      ),
      
      body: Center(
        child: Image.file(
          File(imagePath),
        )
      )
    );
  }
}