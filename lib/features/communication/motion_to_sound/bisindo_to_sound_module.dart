// TAUT Motion-to-Sound (Isyarat BISINDO ke Suara) Module.
// Feature Owner: Roganda Tua Tampubolon (Communication AI Lead).

export 'data/bisindo_detector_service.dart';
export 'data/bisindo_model_manager.dart';
export 'data/bisindo_recognition_service_impl.dart';
export 'data/camera_image_converter.dart';
export 'data/tts_service_impl.dart';
export 'domain/bisindo_labels.dart';
export 'domain/bisindo_recognition_service.dart';
export 'domain/gesture_result.dart';
export 'domain/tts_service.dart';
export 'presentation/motion_to_sound_screen.dart';

import 'presentation/motion_to_sound_screen.dart';

/// Convenient alias for [MotionToSoundScreen] as requested in TAUT architecture specification.
typedef BisindoToSoundScreen = MotionToSoundScreen;
