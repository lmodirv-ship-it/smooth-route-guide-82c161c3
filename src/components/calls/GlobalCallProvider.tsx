/**
 * GlobalCallDialog — renders the in-app call dialog at the app root using
 * the shared CallContext. Must be inside <CallProvider>.
 */
import { useCall } from "@/contexts/CallContext";
import InAppCallDialog from "@/components/calls/InAppCallDialog";

export default function GlobalCallProvider() {
  const call = useCall();

  if (!call.userId) return null;

  return (
    <InAppCallDialog
      incomingCall={call.incomingCall}
      activeCall={call.activeCall}
      localStream={call.localStream}
      remoteStream={call.remoteStream}
      isMuted={call.isMuted}
      isVideoEnabled={call.isVideoEnabled}
      busy={call.busy}
      callDuration={call.callDuration}
      connectionQuality={call.connectionQuality}
      onAccept={call.acceptCall}
      onEnd={call.endCall}
      onToggleMute={call.toggleMute}
      onToggleVideo={call.toggleVideo}
    />
  );
}
