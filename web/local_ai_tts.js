/**
 * Local AI TTS Client Engine (Browser & Hybrid Flutter Web)
 * Clean, reactive interface for on-device AI voice synthesis without cloud APIs.
 */

export class LocalAiTtsEngine {
  constructor(options = {}) {
    this.modelUrl = options.modelUrl || '/models/kokoro-id-82m.onnx';
    this.audioContext = null;
    this.currentSource = null;
    this.worker = null;

    // Reactive Lifecycle States
    this.state = {
      isModelLoading: false,
      isGeneratingAudio: false,
      isPlaying: false,
      error: null,
    };

    this.stateListeners = new Set();
    this._initWorker();
  }

  /**
   * Register a state change subscriber
   * @param {function(object): void} listener
   * @returns {function(): void} unsubscribe
   */
  onStateChange(listener) {
    this.stateListeners.add(listener);
    listener(this.state);
    return () => this.stateListeners.delete(listener);
  }

  _updateState(updates) {
    this.state = { ...this.state, ...updates };
    for (const listener of this.stateListeners) {
      try {
        listener(this.state);
      } catch (err) {
        console.error('TTS State Listener Error:', err);
      }
    }
  }

  _initWorker() {
    this._updateState({ isModelLoading: true, error: null });

    try {
      this.worker = new Worker(new URL('./local_ai_tts.worker.js', import.meta.url), {
        type: 'module',
      });

      this.worker.onmessage = (e) => this._handleWorkerMessage(e);
      this.worker.onerror = (err) => {
        this._updateState({
          isModelLoading: false,
          isGeneratingAudio: false,
          isPlaying: false,
          error: `Worker Error: ${err.message || 'Gagal menjalankan worker'}`,
        });
      };

      this.worker.postMessage({ command: 'INIT', data: { modelUrl: this.modelUrl } });
    } catch (err) {
      this._updateState({
        isModelLoading: false,
        error: `Inisialisasi Worker gagal: ${err.message || err}`,
      });
    }
  }

  _handleWorkerMessage(e) {
    const { type, status, audioBuffer, sampleRate, error } = e.data;

    if (type === 'STATUS') {
      if (status === 'MODEL_READY') {
        this._updateState({ isModelLoading: false, error: null });
      } else if (status === 'GENERATING') {
        this._updateState({ isGeneratingAudio: true });
      }
    } else if (type === 'AUDIO_RESULT') {
      this._updateState({ isGeneratingAudio: false });
      this._playAudioBuffer(new Float32Array(audioBuffer), sampleRate);
    } else if (type === 'ERROR') {
      this._updateState({
        isModelLoading: false,
        isGeneratingAudio: false,
        isPlaying: false,
        error,
      });
    }
  }

  async _playAudioBuffer(samples, sampleRate) {
    try {
      if (!this.audioContext) {
        const AudioCtx = window.AudioContext || window.webkitAudioContext;
        this.audioContext = new AudioCtx({ sampleRate });
      }

      if (this.audioContext.state === 'suspended') {
        await this.audioContext.resume();
      }

      const buffer = this.audioContext.createBuffer(1, samples.length, sampleRate);
      buffer.copyToChannel(samples, 0);

      this.stop(); // Stop any currently playing audio

      const source = this.audioContext.createBufferSource();
      source.buffer = buffer;
      source.connect(this.audioContext.destination);

      source.onended = () => {
        if (this.currentSource === source) {
          this.currentSource = null;
          this._updateState({ isPlaying: false });
        }
      };

      this.currentSource = source;
      this._updateState({ isPlaying: true, error: null });
      source.start();
    } catch (err) {
      this._updateState({
        isPlaying: false,
        error: `Pemutaran audio gagal: ${err.message || err}`,
      });
    }
  }

  /**
   * Speak input text with natural Indonesian intonation
   * @param {string} text
   */
  async speak(text) {
    const trimmed = (text || '').trim();
    if (!trimmed) return;

    if (this.worker) {
      this._updateState({ isGeneratingAudio: true, error: null });
      this.worker.postMessage({ command: 'SPEAK', data: { text: trimmed } });
    } else {
      this._updateState({ error: 'TTS engine belum siap.' });
    }
  }

  /**
   * Stop current audio playback
   */
  stop() {
    if (this.currentSource) {
      try {
        this.currentSource.stop();
      } catch (_) {}
      this.currentSource = null;
    }
    this._updateState({ isPlaying: false, isGeneratingAudio: false });
  }

  /**
   * Cleanup resources
   */
  dispose() {
    this.stop();
    if (this.worker) {
      this.worker.terminate();
      this.worker = null;
    }
    if (this.audioContext) {
      this.audioContext.close().catch(() => {});
      this.audioContext = null;
    }
    this.stateListeners.clear();
  }
}

