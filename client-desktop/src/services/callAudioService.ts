/**
 * Call Audio Service
 *
 * Handles playback of call-related audio sounds (ringtones, dial tones, etc.)
 */

export enum CallAudioType {
  DialTone = 'dial_tone',
  IncomingRingtone = 'ringtone_incoming',
  CallConnected = 'call_connected',
  CallEnded = 'call_ended',
  BusyTone = 'busy_tone',
}

const AUDIO_PATHS: Record<CallAudioType, string> = {
  [CallAudioType.DialTone]: '/audio/dial_tone.mp3',
  [CallAudioType.IncomingRingtone]: '/audio/ringtone_incoming.mp3',
  [CallAudioType.CallConnected]: '/audio/call_connected.mp3',
  [CallAudioType.CallEnded]: '/audio/call_ended.mp3',
  [CallAudioType.BusyTone]: '/audio/busy_tone.mp3',
};

const LOOPING_AUDIO = new Set([CallAudioType.DialTone, CallAudioType.IncomingRingtone]);

class CallAudioServiceClass {
  private dialToneAudio: HTMLAudioElement | null = null;
  private ringtoneAudio: HTMLAudioElement | null = null;
  private effectAudio: HTMLAudioElement | null = null;
  private currentPlaying: CallAudioType | null = null;

  constructor() {
    // Preload audio elements
    this.dialToneAudio = this.createAudio(CallAudioType.DialTone, true);
    this.ringtoneAudio = this.createAudio(CallAudioType.IncomingRingtone, true);
    this.effectAudio = this.createAudio(CallAudioType.CallConnected, false);
  }

  private createAudio(type: CallAudioType, loop: boolean): HTMLAudioElement {
    const audio = new Audio(AUDIO_PATHS[type]);
    audio.loop = loop;
    audio.preload = 'auto';
    return audio;
  }

  private getAudioForType(type: CallAudioType): HTMLAudioElement | null {
    switch (type) {
      case CallAudioType.DialTone:
        return this.dialToneAudio;
      case CallAudioType.IncomingRingtone:
        return this.ringtoneAudio;
      case CallAudioType.CallConnected:
      case CallAudioType.CallEnded:
      case CallAudioType.BusyTone:
        // Update effect audio source if needed
        if (this.effectAudio && this.effectAudio.src !== AUDIO_PATHS[type]) {
          this.effectAudio.src = AUDIO_PATHS[type];
        }
        return this.effectAudio;
      default:
        return null;
    }
  }

  /**
   * Play a specific audio type
   */
  public play(type: CallAudioType): void {
    // Stop any looping audio first
    if (LOOPING_AUDIO.has(type)) {
      this.stopLoopingAudio();
    }

    const audio = this.getAudioForType(type);
    if (!audio) return;

    // For effect audio, update the source
    if (!LOOPING_AUDIO.has(type)) {
      audio.src = AUDIO_PATHS[type];
    }

    audio.currentTime = 0;
    audio.play().catch((e) => {
      console.warn(`Failed to play audio ${type}:`, e);
    });

    if (LOOPING_AUDIO.has(type)) {
      this.currentPlaying = type;
    }
  }

  /**
   * Stop a specific audio type
   */
  public stop(type: CallAudioType): void {
    const audio = this.getAudioForType(type);
    if (audio) {
      audio.pause();
      audio.currentTime = 0;
    }

    if (this.currentPlaying === type) {
      this.currentPlaying = null;
    }
  }

  /**
   * Stop all looping audio (dial tone, ringtone)
   */
  private stopLoopingAudio(): void {
    if (this.dialToneAudio) {
      this.dialToneAudio.pause();
      this.dialToneAudio.currentTime = 0;
    }
    if (this.ringtoneAudio) {
      this.ringtoneAudio.pause();
      this.ringtoneAudio.currentTime = 0;
    }
    this.currentPlaying = null;
  }

  /**
   * Stop all audio playback
   */
  public stopAll(): void {
    this.stopLoopingAudio();
    if (this.effectAudio) {
      this.effectAudio.pause();
      this.effectAudio.currentTime = 0;
    }
  }

  /**
   * Set volume for all audio (0.0 to 1.0)
   */
  public setVolume(volume: number): void {
    const normalizedVolume = Math.max(0, Math.min(1, volume));
    if (this.dialToneAudio) this.dialToneAudio.volume = normalizedVolume;
    if (this.ringtoneAudio) this.ringtoneAudio.volume = normalizedVolume;
    if (this.effectAudio) this.effectAudio.volume = normalizedVolume;
  }

  // Convenience methods
  public playDialTone(): void {
    this.play(CallAudioType.DialTone);
  }

  public stopDialTone(): void {
    this.stop(CallAudioType.DialTone);
  }

  public playIncomingRingtone(): void {
    this.play(CallAudioType.IncomingRingtone);
  }

  public stopIncomingRingtone(): void {
    this.stop(CallAudioType.IncomingRingtone);
  }

  public playCallConnected(): void {
    this.play(CallAudioType.CallConnected);
  }

  public playCallEnded(): void {
    this.play(CallAudioType.CallEnded);
  }

  public playBusyTone(): void {
    this.play(CallAudioType.BusyTone);
  }
}

// Export singleton instance
export const CallAudioService = new CallAudioServiceClass();
