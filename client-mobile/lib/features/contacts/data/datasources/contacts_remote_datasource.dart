import 'package:grpc/grpc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/network/grpc_clients.dart';
import '../../../../generated/auth.pb.dart' as proto;
import '../../../../generated/auth.pbgrpc.dart';
import '../models/contact_model.dart';

/// Remote datasource for contacts operations via gRPC
@injectable
class ContactsRemoteDatasource {
  final GrpcClients _grpcClients;

  ContactsRemoteDatasource(this._grpcClients);

  AuthServiceClient get _authClient => _grpcClients.authClient;

  /// Add a contact
  Future<ContactModel> addContact({
    required String accessToken,
    required String userId,
    String? nickname,
    String? notes,
  }) async {
    final request = proto.AddContactRequest(
      accessToken: accessToken,
      userId: userId,
      nickname: nickname ?? '',
      notes: notes ?? '',
    );

    final response = await _authClient.addContact(request);

    if (response.hasError()) {
      throw GrpcError.custom(response.error.code.value, response.error.message);
    }

    return ContactModel.fromProto(response.contact);
  }

  /// Remove a contact
  Future<void> removeContact({
    required String accessToken,
    required String userId,
  }) async {
    final request = proto.RemoveContactRequest(
      accessToken: accessToken,
      userId: userId,
    );

    final response = await _authClient.removeContact(request);

    if (response.hasError()) {
      throw GrpcError.custom(response.error.code.value, response.error.message);
    }
  }

  /// List contacts with pagination
  Future<ContactsListResponse> listContacts({
    required String accessToken,
    int limit = 50,
    String? cursor,
  }) async {
    final request = proto.ListContactsRequest(
      accessToken: accessToken,
      limit: limit,
      cursor: cursor ?? '',
    );

    final response = await _authClient.listContacts(request);

    if (response.hasError()) {
      throw GrpcError.custom(response.error.code.value, response.error.message);
    }

    final contacts = response.success.contacts
        .map((c) => ContactModel.fromProto(c))
        .toList();

    return ContactsListResponse(
      contacts: contacts,
      nextCursor: response.success.nextCursor.isEmpty
          ? null
          : response.success.nextCursor,
      totalCount: response.success.totalCount,
    );
  }

  /// Get a specific contact
  Future<ContactModel> getContact({
    required String accessToken,
    required String userId,
  }) async {
    final request = proto.GetContactRequest(
      accessToken: accessToken,
      userId: userId,
    );

    final response = await _authClient.getContact(request);

    if (response.hasError()) {
      throw GrpcError.custom(response.error.code.value, response.error.message);
    }

    return ContactModel.fromProto(response.contact);
  }

  /// Update a contact
  Future<ContactModel> updateContact({
    required String accessToken,
    required String userId,
    String? nickname,
    String? notes,
    bool clearNickname = false,
    bool clearNotes = false,
  }) async {
    final request = proto.UpdateContactRequest(
      accessToken: accessToken,
      userId: userId,
      nickname: nickname ?? '',
      notes: notes ?? '',
      clearNickname_5: clearNickname,
      clearNotes_6: clearNotes,
    );

    final response = await _authClient.updateContact(request);

    if (response.hasError()) {
      throw GrpcError.custom(response.error.code.value, response.error.message);
    }

    return ContactModel.fromProto(response.contact);
  }
}

/// Response from listContacts RPC
class ContactsListResponse {
  final List<ContactModel> contacts;
  final String? nextCursor;
  final int totalCount;

  const ContactsListResponse({
    required this.contacts,
    this.nextCursor,
    required this.totalCount,
  });
}
