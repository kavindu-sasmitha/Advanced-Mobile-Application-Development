import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import '../config/agora_config.dart';
 
class AgoraService {
  RtcEngine? _engine;
  RtcEngine? get engine => _engine;

  Future<void> requestPermissions() async {
    await [Permission.camera, Permission.microphone].request();
  }

  /// clientRole: broadcaster (host, camera on) or audience (viewer)
  Future<RtcEngine> initEngine({required bool isBroadcaster}) async {
    await requestPermissions();

    _engine = createAgoraRtcEngine();
    await _engine!.initialize(RtcEngineContext(appId: AgoraConfig.appId));

    await _engine!.enableVideo();
    await _engine!.setChannelProfile(
      ChannelProfileType.channelProfileLiveBroadcasting,
    );
    await _engine!.setClientRole(
      role: isBroadcaster
          ? ClientRoleType.clientRoleBroadcaster
          : ClientRoleType.clientRoleAudience,
    );

    if (isBroadcaster) {
      await _engine!.startPreview();
    }

    return _engine!;
  }

  Future<void> joinChannel(String channelName, {required bool isBroadcaster}) async {
    await _engine!.joinChannel(
      token: AgoraConfig.tempToken ?? '',
      channelId: channelName,
      uid: 0,
      options: ChannelMediaOptions(
        clientRoleType: isBroadcaster
            ? ClientRoleType.clientRoleBroadcaster
            : ClientRoleType.clientRoleAudience,
      ),
    );
  }

  Future<void> leaveChannel() async {
    await _engine?.leaveChannel();
  }

  Future<void> dispose() async {
    await _engine?.leaveChannel();
    await _engine?.release();
    _engine = null;
  }
}
