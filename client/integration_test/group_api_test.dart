import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grpc/grpc.dart';
import 'package:guardyn_client/generated/auth.pb.dart' as auth_proto;
import 'package:guardyn_client/generated/auth.pbgrpc.dart';
import 'package:guardyn_client/generated/messaging.pb.dart' as msg_proto;
import 'package:guardyn_client/generated/messaging.pbgrpc.dart';
import 'package:integration_test/integration_test.dart';

/// Integration test for Group API (GetGroups, GetGroupById, CreateGroup, LeaveGroup)
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late ClientChannel authChannel;
  late ClientChannel messagingChannel;
  late AuthServiceClient authClient;
  late MessagingServiceClient messagingClient;
  String? accessToken;
  String? userId;

  setUpAll(() async {
    // Configure gRPC channels
    // For Android emulator: 10.0.2.2 is the host machine
    // For other platforms: localhost
    final host = defaultTargetPlatform == TargetPlatform.android
        ? '10.0.2.2'
        : 'localhost';

    authChannel = ClientChannel(
      host,
      port: 50051,
      options: const ChannelOptions(credentials: ChannelCredentials.insecure()),
    );

    messagingChannel = ClientChannel(
      host,
      port: 50052,
      options: const ChannelOptions(credentials: ChannelCredentials.insecure()),
    );

    authClient = AuthServiceClient(authChannel);
    messagingClient = MessagingServiceClient(messagingChannel);
  });

  tearDownAll(() async {
    await authChannel.shutdown();
    await messagingChannel.shutdown();
  });

  group('Group API Tests', () {
    testWidgets('Register user and get access token', (tester) async {
      final username = 'test_group_${DateTime.now().millisecondsSinceEpoch}';

      print('📝 Registering user: $username');

      final registerRequest = auth_proto.RegisterRequest(
        username: username,
        password: 'password12345',
        deviceName: 'Test Device',
      );

      final registerResponse = await authClient.register(registerRequest);

      if (registerResponse.hasError()) {
        fail('Registration failed: ${registerResponse.error.message}');
      }

      accessToken = registerResponse.success.accessToken;
      userId = registerResponse.success.userId;

      print('✅ Registered! User ID: $userId');
      print('🔑 Access token length: ${accessToken?.length}');

      expect(accessToken, isNotEmpty);
      expect(userId, isNotEmpty);
    });

    testWidgets('GetGroups - should return empty list for new user', (
      tester,
    ) async {
      expect(accessToken, isNotNull, reason: 'Must register first');

      print('📋 Calling GetGroups...');

      final request = msg_proto.GetGroupsRequest(
        accessToken: accessToken!,
        limit: 50,
      );

      try {
        final response = await messagingClient.getGroups(request);

        if (response.hasError()) {
          print(
            '❌ GetGroups error: ${response.error.code} - ${response.error.message}',
          );
          fail('GetGroups returned error: ${response.error.message}');
        }

        print(
          '✅ GetGroups success! Groups count: ${response.success.groups.length}',
        );
        expect(response.success.groups, isEmpty);
      } catch (e) {
        print('❌ GetGroups exception: $e');
        rethrow;
      }
    });

    testWidgets('CreateGroup - should create a new group', (tester) async {
      expect(accessToken, isNotNull, reason: 'Must register first');

      print('🆕 Creating group...');

      final request = msg_proto.CreateGroupRequest(
        accessToken: accessToken!,
        groupName: 'Test Group ${DateTime.now().millisecondsSinceEpoch}',
        memberUserIds: [], // Just the creator
      );

      try {
        final response = await messagingClient.createGroup(request);

        if (response.hasError()) {
          print(
            '❌ CreateGroup error: ${response.error.code} - ${response.error.message}',
          );
          fail('CreateGroup returned error: ${response.error.message}');
        }

        final groupId = response.success.groupId;
        print('✅ Group created! ID: $groupId');
        expect(groupId, isNotEmpty);
      } catch (e) {
        print('❌ CreateGroup exception: $e');
        rethrow;
      }
    });

    testWidgets('GetGroups - should return created group', (tester) async {
      expect(accessToken, isNotNull, reason: 'Must register first');

      print('📋 Calling GetGroups after creating group...');

      final request = msg_proto.GetGroupsRequest(
        accessToken: accessToken!,
        limit: 50,
      );

      try {
        final response = await messagingClient.getGroups(request);

        if (response.hasError()) {
          print(
            '❌ GetGroups error: ${response.error.code} - ${response.error.message}',
          );
          fail('GetGroups returned error: ${response.error.message}');
        }

        print(
          '✅ GetGroups success! Groups count: ${response.success.groups.length}',
        );
        for (final group in response.success.groups) {
          print('  - ${group.name} (${group.groupId})');
        }

        expect(response.success.groups.length, greaterThanOrEqualTo(1));
      } catch (e) {
        print('❌ GetGroups exception: $e');
        rethrow;
      }
    });

    testWidgets('GetGroupById - should return group details', (tester) async {
      expect(accessToken, isNotNull, reason: 'Must register first');

      // First get groups to get a group ID
      final listRequest = msg_proto.GetGroupsRequest(
        accessToken: accessToken!,
        limit: 1,
      );

      final listResponse = await messagingClient.getGroups(listRequest);
      expect(listResponse.success.groups, isNotEmpty);

      final groupId = listResponse.success.groups.first.groupId;
      print('🔍 Getting group by ID: $groupId');

      final request = msg_proto.GetGroupByIdRequest(
        accessToken: accessToken!,
        groupId: groupId,
      );

      try {
        final response = await messagingClient.getGroupById(request);

        if (response.hasError()) {
          print(
            '❌ GetGroupById error: ${response.error.code} - ${response.error.message}',
          );
          fail('GetGroupById returned error: ${response.error.message}');
        }

        print('✅ GetGroupById success!');
        print('  Name: ${response.success.group.name}');
        print('  Members: ${response.success.group.members.length}');

        expect(response.success.group.groupId, equals(groupId));
      } catch (e) {
        print('❌ GetGroupById exception: $e');
        rethrow;
      }
    });
  });
}
