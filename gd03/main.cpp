#include <SDL2/SDL.h>
#include "WickedEngine.h"


#ifndef GAME_DATA_DIR
#define GAME_DATA_DIR "/gdtv_01_project_boost/"
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
  auto content_dir_path    = cur_dir_path + "/../../gd03" + GAME_DATA_DIR;
  auto shader_src_dir_path = cur_dir_path + "/../../3rdparty/turanszkij_WickedEngine/WickedEngine/shaders/";
  auto shader_bin_dir_path = cur_dir_path + "/../../.shaders/";
#else
  auto content_dir_path    = cur_dir_path + GAME_DATA_DIR;
  auto shader_src_dir_path = cur_dir_path + GAME_DATA_DIR + "shaders/";
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
      sdl2::make_window("Updating shaders, please wait a minute...", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, 800,
                        500, SDL_WINDOW_SHOWN | SDL_WINDOW_VULKAN | SDL_WINDOW_ALLOW_HIGHDPI | SDL_WINDOW_RESIZABLE);
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

  while (true) {
    SDL_PumpEvents();
    app.Run();

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
  wi::jobsystem::ShutDown();
  SDL_DestroyWindow(app.window);
  SDL_Quit();
  return 0;
}
