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
import 'package:guardyn_client/features/calls/domain/repositories/call_repository.dart'
    as _i516;
import 'package:guardyn_client/features/calls/domain/usecases/accept_call.dart'
    as _i520;
import 'package:guardyn_client/features/calls/domain/usecases/call_controls.dart'
    as _i659;
import 'package:guardyn_client/features/calls/domain/usecases/end_call.dart'
    as _i148;
import 'package:guardyn_client/features/calls/domain/usecases/get_call_history.dart'
    as _i975;
import 'package:guardyn_client/features/calls/domain/usecases/initiate_call.dart'
    as _i468;
import 'package:guardyn_client/features/calls/domain/usecases/usecases.dart'
    as _i286;
import 'package:guardyn_client/features/calls/presentation/bloc/call_bloc.dart'
    as _i785;
import 'package:guardyn_client/features/calls/presentation/bloc/call_history_bloc.dart'
    as _i930;
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
import 'package:guardyn_client/features/groups/domain/usecases/delete_group.dart'
    as _i144;
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
import 'package:guardyn_client/features/groups/domain/usecases/update_group.dart'
    as _i319;
import 'package:guardyn_client/features/groups/presentation/bloc/group_bloc.dart'
    as _i801;
import 'package:guardyn_client/features/media/domain/repositories/media_repository.dart'
    as _i573;
import 'package:guardyn_client/features/media/domain/usecases/delete_media.dart'
    as _i137;
import 'package:guardyn_client/features/media/domain/usecases/download_media.dart'
    as _i656;
import 'package:guardyn_client/features/media/domain/usecases/get_media_metadata.dart'
    as _i155;
import 'package:guardyn_client/features/media/domain/usecases/get_thumbnail_url.dart'
    as _i142;
import 'package:guardyn_client/features/media/domain/usecases/list_media.dart'
    as _i767;
import 'package:guardyn_client/features/media/domain/usecases/manage_media_cache.dart'
    as _i703;
import 'package:guardyn_client/features/media/domain/usecases/upload_media.dart'
    as _i831;
import 'package:guardyn_client/features/media/presentation/bloc/media_bloc.dart'
    as _i104;
import 'package:guardyn_client/features/messaging/data/datasources/key_exchange_datasource.dart'
    as _i727;
import 'package:guardyn_client/features/messaging/data/datasources/message_remote_datasource.dart'
    as _i304;
import 'package:guardyn_client/features/messaging/data/datasources/notification_remote_datasource.dart'
    as _i744;
import 'package:guardyn_client/features/messaging/data/datasources/websocket_datasource.dart'
    as _i124;
import 'package:guardyn_client/features/messaging/data/repositories/message_repository_impl.dart'
    as _i1009;
import 'package:guardyn_client/features/messaging/data/repositories/notification_repository_impl.dart'
    as _i421;
import 'package:guardyn_client/features/messaging/domain/repositories/message_repository.dart'
    as _i276;
import 'package:guardyn_client/features/messaging/domain/usecases/clear_chat.dart'
    as _i315;
import 'package:guardyn_client/features/messaging/domain/usecases/decrypt_message.dart'
    as _i778;
import 'package:guardyn_client/features/messaging/domain/usecases/delete_message.dart'
    as _i273;
import 'package:guardyn_client/features/messaging/domain/usecases/get_messages.dart'
    as _i11;
import 'package:guardyn_client/features/messaging/domain/usecases/mark_as_read.dart'
    as _i892;
import 'package:guardyn_client/features/messaging/domain/usecases/mute_conversation.dart'
    as _i380;
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
    gh.factory<_i744.NotificationRemoteDatasource>(
      () => _i744.NotificationRemoteDatasource(gh<_i231.GrpcClients>()),
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
    gh.factory<_i380.MuteConversationRepository>(
      () => _i421.NotificationRepositoryImpl(
        gh<_i744.NotificationRemoteDatasource>(),
        gh<_i879.SecureStorage>(),
      ),
    );
    gh.factory<_i276.MessageRepository>(
      () => _i1009.MessageRepositoryImpl(
        gh<_i304.MessageRemoteDatasource>(),
        gh<_i727.KeyExchangeDatasource>(),
        gh<_i879.SecureStorage>(),
        gh<_i440.CryptoService>(),
      ),
    );
    gh.factory<_i659.ToggleMute>(
      () => _i659.ToggleMute(gh<_i516.CallRepository>()),
    );
    gh.factory<_i659.ToggleVideo>(
      () => _i659.ToggleVideo(gh<_i516.CallRepository>()),
    );
    gh.factory<_i659.ToggleSpeaker>(
      () => _i659.ToggleSpeaker(gh<_i516.CallRepository>()),
    );
    gh.factory<_i659.SwitchCamera>(
      () => _i659.SwitchCamera(gh<_i516.CallRepository>()),
    );
    gh.factory<_i975.GetCallHistory>(
      () => _i975.GetCallHistory(gh<_i516.CallRepository>()),
    );
    gh.factory<_i520.AcceptCall>(
      () => _i520.AcceptCall(gh<_i516.CallRepository>()),
    );
    gh.factory<_i468.InitiateCall>(
      () => _i468.InitiateCall(gh<_i516.CallRepository>()),
    );
    gh.factory<_i148.EndCall>(() => _i148.EndCall(gh<_i516.CallRepository>()));
    gh.factory<_i148.RejectCall>(
      () => _i148.RejectCall(gh<_i516.CallRepository>()),
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
    gh.factory<_i930.CallHistoryBloc>(
      () => _i930.CallHistoryBloc(getCallHistory: gh<_i975.GetCallHistory>()),
    );
    gh.factory<_i703.ManageMediaCache>(
      () => _i703.ManageMediaCache(gh<_i573.MediaRepository>()),
    );
    gh.factory<_i831.UploadMedia>(
      () => _i831.UploadMedia(gh<_i573.MediaRepository>()),
    );
    gh.factory<_i142.GetThumbnailUrl>(
      () => _i142.GetThumbnailUrl(gh<_i573.MediaRepository>()),
    );
    gh.factory<_i656.DownloadMedia>(
      () => _i656.DownloadMedia(gh<_i573.MediaRepository>()),
    );
    gh.factory<_i767.ListMedia>(
      () => _i767.ListMedia(gh<_i573.MediaRepository>()),
    );
    gh.factory<_i137.DeleteMedia>(
      () => _i137.DeleteMedia(gh<_i573.MediaRepository>()),
    );
    gh.factory<_i155.GetMediaMetadata>(
      () => _i155.GetMediaMetadata(gh<_i573.MediaRepository>()),
    );
    gh.factory<_i785.CallBloc>(
      () => _i785.CallBloc(
        initiateCall: gh<_i286.InitiateCall>(),
        acceptCall: gh<_i286.AcceptCall>(),
        endCall: gh<_i286.EndCall>(),
        rejectCall: gh<_i286.RejectCall>(),
        toggleMute: gh<_i286.ToggleMute>(),
        toggleVideo: gh<_i286.ToggleVideo>(),
        toggleSpeaker: gh<_i286.ToggleSpeaker>(),
        switchCamera: gh<_i286.SwitchCamera>(),
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
    gh.factory<_i104.MediaBloc>(
      () => _i104.MediaBloc(
        uploadMedia: gh<_i831.UploadMedia>(),
        downloadMedia: gh<_i656.DownloadMedia>(),
        listMedia: gh<_i767.ListMedia>(),
        getMediaMetadata: gh<_i155.GetMediaMetadata>(),
        getThumbnailUrl: gh<_i142.GetThumbnailUrl>(),
        deleteMedia: gh<_i137.DeleteMedia>(),
        manageMediaCache: gh<_i703.ManageMediaCache>(),
      ),
    );
    gh.factory<_i892.MarkAsRead>(
      () => _i892.MarkAsRead(gh<_i276.MessageRepository>()),
    );
    gh.factory<_i1073.SendMessage>(
      () => _i1073.SendMessage(gh<_i276.MessageRepository>()),
    );
    gh.factory<_i315.ClearChat>(
      () => _i315.ClearChat(gh<_i276.MessageRepository>()),
    );
    gh.factory<_i273.DeleteMessage>(
      () => _i273.DeleteMessage(gh<_i276.MessageRepository>()),
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
    gh.factory<_i1004.GetGroupById>(
      () => _i1004.GetGroupById(gh<_i598.GroupRepository>()),
    );
    gh.factory<_i144.DeleteGroup>(
      () => _i144.DeleteGroup(gh<_i598.GroupRepository>()),
    );
    gh.factory<_i319.UpdateGroup>(
      () => _i319.UpdateGroup(gh<_i598.GroupRepository>()),
    );
    gh.factory<_i387.RemoveGroupMember>(
      () => _i387.RemoveGroupMember(gh<_i598.GroupRepository>()),
    );
    gh.factory<_i441.GetGroups>(
      () => _i441.GetGroups(gh<_i598.GroupRepository>()),
    );
    gh.factory<_i696.GetGroupMessages>(
      () => _i696.GetGroupMessages(gh<_i598.GroupRepository>()),
    );
    gh.factory<_i604.LeaveGroup>(
      () => _i604.LeaveGroup(gh<_i598.GroupRepository>()),
    );
    gh.factory<_i969.SendGroupMessage>(
      () => _i969.SendGroupMessage(gh<_i598.GroupRepository>()),
    );
    gh.factory<_i238.CreateGroup>(
      () => _i238.CreateGroup(gh<_i598.GroupRepository>()),
    );
    gh.factory<_i981.AddGroupMember>(
      () => _i981.AddGroupMember(gh<_i598.GroupRepository>()),
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
    gh.factory<_i248.MessageBloc>(
      () => _i248.MessageBloc(
        sendMessage: gh<_i1073.SendMessage>(),
        getMessages: gh<_i11.GetMessages>(),
        receiveMessages: gh<_i717.ReceiveMessages>(),
        markAsRead: gh<_i892.MarkAsRead>(),
        decryptMessage: gh<_i778.DecryptMessage>(),
        clearChat: gh<_i315.ClearChat>(),
        deleteMessage: gh<_i273.DeleteMessage>(),
      ),
    );
    gh.factory<_i801.GroupBloc>(
      () => _i801.GroupBloc(
        createGroup: gh<_i238.CreateGroup>(),
        deleteGroup: gh<_i144.DeleteGroup>(),
        getGroups: gh<_i441.GetGroups>(),
        getGroupById: gh<_i1004.GetGroupById>(),
        sendGroupMessage: gh<_i969.SendGroupMessage>(),
        getGroupMessages: gh<_i696.GetGroupMessages>(),
        addGroupMember: gh<_i981.AddGroupMember>(),
        removeGroupMember: gh<_i387.RemoveGroupMember>(),
        leaveGroup: gh<_i604.LeaveGroup>(),
        updateGroup: gh<_i319.UpdateGroup>(),
      ),
    );
    return this;
  }
}
