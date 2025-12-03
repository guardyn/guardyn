// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:guardyn_client/core/crypto/crypto_service.dart' as _i440;
import 'package:guardyn_client/core/network/grpc_clients.dart' as _i231;
import 'package:guardyn_client/core/storage/secure_storage.dart' as _i879;
import 'package:guardyn_client/features/groups/data/datasources/group_remote_datasource.dart'
    as _i747;
import 'package:guardyn_client/features/groups/data/repositories/group_repository_impl.dart'
    as _i417;
import 'package:guardyn_client/features/groups/domain/repositories/group_repository.dart'
    as _i598;
import 'package:guardyn_client/features/groups/domain/usecases/add_group_member.dart'
    as _i981;
import 'package:guardyn_client/features/groups/domain/usecases/create_group.dart'
    as _i238;
import 'package:guardyn_client/features/groups/domain/usecases/get_group_by_id.dart'
    as _i1004;
import 'package:guardyn_client/features/groups/domain/usecases/get_group_messages.dart'
    as _i696;
import 'package:guardyn_client/features/groups/domain/usecases/get_groups.dart'
    as _i441;
import 'package:guardyn_client/features/groups/domain/usecases/leave_group.dart'
    as _i604;
import 'package:guardyn_client/features/groups/domain/usecases/remove_group_member.dart'
    as _i387;
import 'package:guardyn_client/features/groups/domain/usecases/send_group_message.dart'
    as _i969;
import 'package:guardyn_client/features/groups/presentation/bloc/group_bloc.dart'
    as _i801;
import 'package:guardyn_client/features/messaging/data/datasources/key_exchange_datasource.dart'
    as _i727;
import 'package:guardyn_client/features/messaging/data/datasources/message_remote_datasource.dart'
    as _i304;
import 'package:guardyn_client/features/messaging/data/datasources/websocket_datasource.dart'
    as _i124;
import 'package:guardyn_client/features/messaging/data/repositories/message_repository_impl.dart'
    as _i1009;
import 'package:guardyn_client/features/messaging/domain/repositories/message_repository.dart'
    as _i276;
import 'package:guardyn_client/features/messaging/domain/usecases/decrypt_message.dart'
    as _i778;
import 'package:guardyn_client/features/messaging/domain/usecases/get_messages.dart'
    as _i11;
import 'package:guardyn_client/features/messaging/domain/usecases/mark_as_read.dart'
    as _i892;
import 'package:guardyn_client/features/messaging/domain/usecases/receive_messages.dart'
    as _i717;
import 'package:guardyn_client/features/messaging/domain/usecases/send_message.dart'
    as _i1073;
import 'package:guardyn_client/features/messaging/presentation/bloc/message_bloc.dart'
    as _i248;
import 'package:guardyn_client/features/presence/data/datasources/presence_remote_datasource.dart'
    as _i526;
import 'package:guardyn_client/features/presence/data/repositories/presence_repository_impl.dart'
    as _i241;
import 'package:guardyn_client/features/presence/domain/repositories/presence_repository.dart'
    as _i5;
import 'package:guardyn_client/features/presence/domain/usecases/get_bulk_presence.dart'
    as _i336;
import 'package:guardyn_client/features/presence/domain/usecases/get_user_presence.dart'
    as _i769;
import 'package:guardyn_client/features/presence/domain/usecases/send_heartbeat.dart'
    as _i56;
import 'package:guardyn_client/features/presence/domain/usecases/send_typing_indicator.dart'
    as _i76;
import 'package:guardyn_client/features/presence/domain/usecases/update_my_status.dart'
    as _i739;
import 'package:guardyn_client/features/presence/presentation/bloc/presence_bloc.dart'
    as _i2;
import 'package:injectable/injectable.dart' as _i526;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    gh.lazySingleton<_i124.WebSocketDatasource>(
      () => _i124.WebSocketDatasource(),
      dispose: (i) => i.dispose(),
    );
    gh.factory<_i304.MessageRemoteDatasource>(
      () => _i304.MessageRemoteDatasource(gh<_i231.GrpcClients>()),
    );
    gh.factory<_i747.GroupRemoteDatasource>(
      () => _i747.GroupRemoteDatasource(gh<_i231.GrpcClients>()),
    );
    gh.factory<_i526.PresenceRemoteDatasource>(
      () => _i526.PresenceRemoteDatasource(gh<_i231.GrpcClients>()),
    );
    gh.factory<_i276.MessageRepository>(
      () => _i1009.MessageRepositoryImpl(
        gh<_i304.MessageRemoteDatasource>(),
        gh<_i727.KeyExchangeDatasource>(),
        gh<_i879.SecureStorage>(),
        gh<_i440.CryptoService>(),
      ),
    );
    gh.factory<_i801.GroupBloc>(
      () => _i801.GroupBloc(
        createGroup: gh<_i238.CreateGroup>(),
        getGroups: gh<_i441.GetGroups>(),
        getGroupById: gh<_i1004.GetGroupById>(),
        sendGroupMessage: gh<_i969.SendGroupMessage>(),
        getGroupMessages: gh<_i696.GetGroupMessages>(),
        addGroupMember: gh<_i981.AddGroupMember>(),
        removeGroupMember: gh<_i387.RemoveGroupMember>(),
        leaveGroup: gh<_i604.LeaveGroup>(),
      ),
    );
    gh.lazySingleton<_i598.GroupRepository>(
      () => _i417.GroupRepositoryImpl(
        gh<_i747.GroupRemoteDatasource>(),
        gh<_i879.SecureStorage>(),
      ),
    );
    gh.factory<_i5.PresenceRepository>(
      () => _i241.PresenceRepositoryImpl(
        gh<_i526.PresenceRemoteDatasource>(),
        gh<_i879.SecureStorage>(),
      ),
    );
    gh.factory<_i56.SendHeartbeat>(
      () => _i56.SendHeartbeat(gh<_i5.PresenceRepository>()),
    );
    gh.factory<_i76.SendTypingIndicator>(
      () => _i76.SendTypingIndicator(gh<_i5.PresenceRepository>()),
    );
    gh.factory<_i336.GetBulkPresence>(
      () => _i336.GetBulkPresence(gh<_i5.PresenceRepository>()),
    );
    gh.factory<_i739.UpdateMyStatus>(
      () => _i739.UpdateMyStatus(gh<_i5.PresenceRepository>()),
    );
    gh.factory<_i769.GetUserPresence>(
      () => _i769.GetUserPresence(gh<_i5.PresenceRepository>()),
    );
    gh.factory<_i892.MarkAsRead>(
      () => _i892.MarkAsRead(gh<_i276.MessageRepository>()),
    );
    gh.factory<_i1073.SendMessage>(
      () => _i1073.SendMessage(gh<_i276.MessageRepository>()),
    );
    gh.factory<_i11.GetMessages>(
      () => _i11.GetMessages(gh<_i276.MessageRepository>()),
    );
    gh.factory<_i778.DecryptMessage>(
      () => _i778.DecryptMessage(gh<_i276.MessageRepository>()),
    );
    gh.factory<_i717.ReceiveMessages>(
      () => _i717.ReceiveMessages(gh<_i276.MessageRepository>()),
    );
    gh.factory<_i248.MessageBloc>(
      () => _i248.MessageBloc(
        sendMessage: gh<_i1073.SendMessage>(),
        getMessages: gh<_i11.GetMessages>(),
        receiveMessages: gh<_i717.ReceiveMessages>(),
        markAsRead: gh<_i892.MarkAsRead>(),
        decryptMessage: gh<_i778.DecryptMessage>(),
      ),
    );
    gh.factory<_i2.PresenceBloc>(
      () => _i2.PresenceBloc(
        getUserPresence: gh<_i769.GetUserPresence>(),
        getBulkPresence: gh<_i336.GetBulkPresence>(),
        updateMyStatus: gh<_i739.UpdateMyStatus>(),
        sendTypingIndicator: gh<_i76.SendTypingIndicator>(),
        sendHeartbeat: gh<_i56.SendHeartbeat>(),
        presenceRepository: gh<_i5.PresenceRepository>(),
      ),
    );
    return this;
  }
}
