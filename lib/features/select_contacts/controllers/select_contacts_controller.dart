import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/features/select_contacts/repository/select_contact_repository.dart';

final getContactsProvider = FutureProvider((ref) {
  final selectContactRepository = ref.watch(SelectContactsRepositoryProvider);
  return selectContactRepository.getContacts();
});
final SelectContactControllerProvider = Provider((ref) {
  final SelectContactRepository = ref.watch(SelectContactsRepositoryProvider);
  return SelectContactController(
      ref: ref, selectContactRepository: SelectContactRepository);
});

class SelectContactController {
  final ProviderRef ref;
  final SelectContactRepository selectContactRepository;

  SelectContactController(
      {required this.ref, required this.selectContactRepository});

  void selectContact(Contact selectedContact, BuildContext context) async {
    selectContactRepository.selectContact(selectedContact, context);
  }
}
