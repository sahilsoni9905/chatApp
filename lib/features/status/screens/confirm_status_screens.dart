import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/features/status/controllers/status_controller.dart';
import 'package:whatsapp_clone/utils/colors.dart';

class ConfirmStatusScreen extends ConsumerWidget {
  static const String routeName = '/confirm-status-screen';
  final File file;
  const ConfirmStatusScreen({super.key, required this.file});

  void addStatus(WidgetRef ref, BuildContext context) {
    print("reached to part 1");
    ref.read(StatusControllerProvider).addStatus(file, context);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      //aspect ratio can be used to properly show ur image
      body: Center(
        child: AspectRatio(
          aspectRatio: 9 / 16,
          child: Image.file(file),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(
          Icons.done,
          color: Colors.white,
        ),
        onPressed: () => addStatus(ref, context),
        backgroundColor: tabColor,
      ),
    );
  }
}
