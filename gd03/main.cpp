#include <SDL2/SDL.h>
#include "WickedEngine.h"
#include "wiInput.h"
#include "wiRenderPath3D.h"
#include "wiRenderer.h"


#ifndef GD_GAME_NAME
#define GD_GAME_NAME "doesnt_exist"
#endif


int main(int argc, char** argv) {
  std::string cur_dir_path = wi::helper::GetCurrentPath();
  {
    std::string exe_dir_path = wi::helper::GetDirectoryFromPath(wi::helper::GetExecutablePath());
    if (cur_dir_path != exe_dir_path) {
      int err_code = chdir(exe_dir_path.c_str());   // libdxcompiler.so sits here but Wicked expects it in current dir
      if (err_code != 0)
        return err_code;
      cur_dir_path = exe_dir_path;
    }
  }
#if DEVBUILD
  auto content_dir_path    = cur_dir_path + "/../../gd03/" + GD_GAME_NAME + "/";
  auto shader_src_dir_path = cur_dir_path + "/../../3rdparty/turanszkij_WickedEngine/WickedEngine/shaders/";
  auto shader_bin_dir_path = cur_dir_path + "/../../.shaders/";
#else
  auto content_dir_path    = cur_dir_path + "/" + GD_GAME_NAME + "/";
  auto shader_src_dir_path = cur_dir_path + "/" + GD_GAME_NAME + "/shaders/";
  auto shader_bin_dir_path = cur_dir_path + "/.shaders/";
#endif

  wi::helper::DirectoryCreate(shader_bin_dir_path + "spirv");
  wi::arguments::Parse(argc, argv);

  // SDL init & window creation
  if (0 != *sdl2::make_sdlsystem(SDL_INIT_EVERYTHING | SDL_INIT_EVENTS)) {
    fprintf(stderr, "Failed to make_sdlsystem: %s", SDL_GetError());
    SDL_Quit();
    exit(1);
  }
  auto sdl_win =
      sdl2::make_window("Updating shaders, please wait a minute...", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, 720,
                        450, SDL_WINDOW_SHOWN | SDL_WINDOW_VULKAN | SDL_WINDOW_ALLOW_HIGHDPI | SDL_WINDOW_RESIZABLE);
  if (!sdl_win) {
    fprintf(stderr, "Failed to make_window: %s", SDL_GetError());
    SDL_Quit();
    exit(1);
  }


  wi::Application app;
  app.infoDisplay.active    = true;
  app.infoDisplay.watermark = false;
  app.infoDisplay.fpsinfo   = true;
  wi::renderer::SetShaderSourcePath(shader_src_dir_path);
  wi::renderer::SetShaderPath(shader_bin_dir_path);
  app.SetWindow(sdl_win.get());
  app.Initialize();
  wi::RenderPath3D path;
  app.ActivatePath(&path);
  void setupGfx(wi::RenderPath3D * rp);
  setupGfx(&path);

  wi::input::HidePointer(true);
  while (true) {
    SDL_PumpEvents();
    app.Run();
    wi::RenderPath3D* rp = (wi::RenderPath3D*) app.GetActivePath();
    if (rp != nullptr) {
      rp->setTonemap(wi::renderer::Tonemap::ACES);
      rp->setExposure(1);
    }

    static bool did_load_script_file = false;
    if ((!did_load_script_file) && wi::initializer::IsInitializeFinished()) {
      did_load_script_file = true;
      SDL_SetWindowTitle(app.window, wi::version::GetVersionString());
      if (!wi::lua::RunFile(content_dir_path + "main.lua"))
        goto quit;
    }

    SDL_Event event;
    while (SDL_PollEvent(&event) != 0) {
      switch (event.type) {
        case SDL_QUIT:
          goto quit;
        case SDL_KEYDOWN:
          switch (event.key.keysym.sym) {
#if DEVBUILD
            case SDLK_q:   // quit via Ctrl+Q?
              if (event.key.keysym.mod & KMOD_CTRL)
                goto quit;
              break;
#endif
            case SDLK_F11:
              bool was_fullscreen =
                  SDL_WINDOW_FULLSCREEN_DESKTOP == (SDL_GetWindowFlags(app.window) & SDL_WINDOW_FULLSCREEN_DESKTOP);
              SDL_SetWindowFullscreen(app.window, was_fullscreen ? 0 : SDL_WINDOW_FULLSCREEN_DESKTOP);
              break;
          }
          if (event.key.keysym.scancode == SDL_SCANCODE_BACKSPACE ||
              event.key.keysym.scancode == SDL_SCANCODE_KP_BACKSPACE)
            wi::gui::TextInputField::DeleteFromInput();
          break;
        case SDL_TEXTINPUT:
          if (event.text.text[0] >= 21)
            wi::gui::TextInputField::AddInput(event.text.text[0]);
          break;
        case SDL_WINDOWEVENT:
          switch (event.window.event) {
            case SDL_WINDOWEVENT_CLOSE:
              goto quit;
            case SDL_WINDOWEVENT_RESIZED:
              app.SetWindow(app.window);
              break;
            case SDL_WINDOWEVENT_FOCUS_LOST:
              app.is_window_active = false;
              break;
            case SDL_WINDOWEVENT_FOCUS_GAINED:
              app.is_window_active = true;
              break;
          }
          break;
      }
      wi::input::sdlinput::ProcessEvent(event);
    }
  }

quit:
  wi::input::HidePointer(false);
  wi::jobsystem::ShutDown();
  SDL_DestroyWindow(app.window);
  SDL_Quit();
  return 0;
}

void setupGfx(wi::RenderPath3D* rp) {
  wi::renderer::SetShadowProps2D(4096);
  wi::renderer::SetShadowPropsCube(2048);
  wi::renderer::SetShadowLODOverrideEnabled(false);
  wi::renderer::SetAdvancedLightCulling(true);
  wi::renderer::SetCapsuleShadowEnabled(true);
  wi::renderer::SetCapsuleShadowAngle(22);
  wi::renderer::SetCapsuleShadowFade(1);
  wi::renderer::SetOcclusionCullingEnabled(true);
  wi::renderer::SetTessellationEnabled(true);

  rp->resolutionScale = 0.88f;
  rp->setAO(wi::RenderPath3D::AO_MSAO);
  rp->setAOPower(0.77f);
  rp->setSSREnabled(true);
  rp->setSSGIEnabled(true);
  rp->setSSGIDepthRejection(1.23f);
  rp->setShadowsEnabled(true);
  rp->setReflectionsEnabled(true);
  rp->setFXAAEnabled(true);
  rp->setBloomEnabled(true);
  rp->setBloomThreshold(3.21f);
  rp->setVolumeLightsEnabled(true);
  rp->setLightShaftsEnabled(true);
  rp->setLightShaftsStrength(0.321f);
  rp->setLightShaftsFadeSpeed(4);
  rp->setMotionBlurEnabled(true);
  rp->setMotionBlurStrength(44);
  rp->setDitherEnabled(true);
  rp->setMSAASampleCount(8);
  rp->setSharpenFilterEnabled(true);
  rp->setSharpenFilterAmount(1.11f);
  rp->setEyeAdaptionEnabled(true);
  rp->setEyeAdaptionRate(4);
  rp->setEyeAdaptionKey(0.123f);
  rp->setTonemap(wi::renderer::Tonemap::ACES);
  rp->setExposure(1);
  rp->setBrightness(0);
  rp->setContrast(1.11f);
  rp->setSaturation(0.6f);
  rp->setChromaticAberrationEnabled(true);
  rp->setChromaticAberrationAmount(3.21f);
  rp->setMeshBlendEnabled(true);
  rp->setOcclusionCullingEnabled(true);
}
