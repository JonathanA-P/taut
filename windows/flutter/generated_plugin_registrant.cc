//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

<<<<<<< HEAD
#include <speech_to_text_windows/speech_to_text_windows.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  SpeechToTextWindowsRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("SpeechToTextWindows"));
=======
#include <flutter_tts/flutter_tts_plugin.h>
#include <app_links/app_links_plugin_c_api.h>
#include <url_launcher_windows/url_launcher_windows.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  FlutterTtsPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("FlutterTtsPlugin"));
  AppLinksPluginCApiRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("AppLinksPluginCApi"));
  UrlLauncherWindowsRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("UrlLauncherWindows"));
>>>>>>> origin/feature/speech-to-text
}
