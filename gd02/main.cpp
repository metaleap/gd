#include "WickedEngine.h"
#include <SDL2/SDL.h>


#define WHICH "character_controller"
// #define WHICH "fighting_game"


int main(int argc, char** argv) {
  wi::arguments::Parse(argc, argv);

  if (0 != *sdl2::make_sdlsystem(SDL_INIT_EVERYTHING | SDL_INIT_EVENTS)) {
    fprintf(stderr, "Failed to init SDL: %s", SDL_GetError());
    SDL_Quit();
    exit(1);
  }

  auto sdl_win =
      sdl2::make_window("Updating shaders, please wait a minute...", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, 960,
                        600, SDL_WINDOW_SHOWN | SDL_WINDOW_VULKAN | SDL_WINDOW_ALLOW_HIGHDPI | SDL_WINDOW_RESIZABLE);
  if (!sdl_win) {
    fprintf(stderr, "Failed to make window: %s", SDL_GetError());
    SDL_Quit();
    exit(1);
  }

  wi::Application app;
  wi::renderer::SetShaderPath("3rdparty/turanszkij_WickedEngine/.shaders/");
  wi::renderer::SetShaderSourcePath("3rdparty/turanszkij_WickedEngine/WickedEngine/shaders/");
  app.SetWindow(sdl_win.get());
  app.Initialize();
  wi::RenderPath3D path;
  app.ActivatePath(&path);

  bool      quit = false;
  SDL_Event event;
  while (!quit) {
    SDL_PumpEvents();
    app.Run();

    static bool did_load_script_file = false;
    if ((!did_load_script_file) && wi::initializer::IsInitializeFinished()) {
      did_load_script_file = true;
      SDL_SetWindowTitle(app.window, wi::version::GetVersionString());
      // SDL_SetWindowFullscreen(app.window, SDL_WINDOW_FULLSCREEN_DESKTOP);
      wi::lua::RunFile("3rdparty/turanszkij_WickedEngine/Content/scripts/" WHICH "/" WHICH ".lua");
    }

    while (SDL_PollEvent(&event) != 0) {
      switch (event.type) {
        case SDL_QUIT:
          quit = true;
          break;
        case SDL_WINDOWEVENT:
          switch (event.window.event) {
            case SDL_WINDOWEVENT_CLOSE:
              quit = true;
              break;
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

  wi::jobsystem::ShutDown();
  SDL_DestroyWindow(app.window);
  SDL_Quit();
  return 0;
}
