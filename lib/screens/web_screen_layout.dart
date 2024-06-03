import 'package:flutter/material.dart';
import 'package:whatsapp_clone/widgets/contact_list.dart';

class WebScreen extends StatelessWidget {
  const WebScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Column(
          children: [
            // web profile
            // web search bar
            // contact list
            ContactList(),
          ],
        ),
      ],
    ));
  }
}
