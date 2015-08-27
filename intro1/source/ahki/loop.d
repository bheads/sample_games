module ahki.loop;

import core.sync.barrier;

import std.concurrency;
import std.conv;
import std.format;

import dini;

import ahki.sdl;


int loop(SDL_Renderer* render) {
    SDL_Event event;
    bool running = true;

    // Core game loop
    ulong lastFrame = SDL_GetPerformanceCounter(), currentFrame;
    double elapsed;

    double aiLag, phyLag, scriptLag;
    double aiStep = 1_000 / 8, phyStep = 50, scriptStep = 1_000 / 10;

    GAME: while(running) {
        // compute delta
        currentFrame = SDL_GetPerformanceCounter();
        elapsed = (cast(double) (currentFrame - lastFrame) * 1_000) / SDL_GetPerformanceFrequency(); // ms
        lastFrame = currentFrame;
        aiLag += elapsed;
        phyLag += elapsed;
        scriptLag += elapsed;

        // Find events
        while (SDL_PollEvent(&event)) {
            switch(event.type) {
            case SDL_QUIT:
                running = false;
                break GAME;
            default:
            }
        }

        // Update stages
        while(aiLag >= aiStep ) {
            // update ai
            aiLag -= aiStep;
        }

        SDL_RenderClear(render);
        
        // Draw game world here!

        // Draw interface last

        SDL_RenderPresent(render);

        // delay game loop here
    }

    return 0;
}


int start(string[] args) {
    Config config;
    auto ini = Ini.Parse("ahki.conf");
    config.width = ini["window"].getKey("width").to!int; 
    config.height = ini["window"].getKey("height").to!int; 
    config.fullscreen = ini["window"].getKey("fullscreen").to!bool;


    sdl_init();
    scope(exit) sdl_quit();
    
    // splash window
    {
        SDL_Window* window;
        SDL_Renderer* render;
        // Load the splash image first, this will be used as the splash window size
        auto splashSurface = enforce(IMG_Load(`data\images\splash.png`), format("Failed to load splash assets due to %s", IMG_GetError.to!string)); 
        enforce(SDL_CreateWindowAndRenderer(splashSurface.w, splashSurface.h, SDL_WINDOW_BORDERLESS, &window, &render) == 0, format("Failed to create window due to %s", SDL_GetError().to!string));
        SDL_SetRenderDrawColor(render, 0, 0, 0, 255); // black ground
        scope(exit) SDL_DestroyWindow(window);
        scope(exit) SDL_DestroyRenderer(render);

        // load in the spash image
        auto splashTexture = SDL_CreateTextureFromSurface(render, splashSurface);
        scope(exit) SDL_DestroyTexture(splashTexture);
        SDL_FreeSurface(splashSurface);


        // Draw the splash
        SDL_RenderClear(render);
        SDL_RenderCopy(render, splashTexture, null, null);
        SDL_RenderPresent(render);

        barrier = new Barrier(2);
        spawn(&init);
        SDL_Delay(2000); // show our splash for at least 2secs
        barrier.wait();
    }


    // game window
    SDL_Window* window;
    SDL_Renderer* render;
    enforce(SDL_CreateWindowAndRenderer(config.width, config.height,
            SDL_WINDOW_OPENGL | (config.fullscreen ? SDL_WINDOW_FULLSCREEN : 0),
            &window, &render) == 0, format("Failed to create window due to %s", SDL_GetError().to!string));

    debug SDL_SetRenderDrawColor(render, 0, 0, 255, 255); // use blue for debugging
    else SDL_SetRenderDrawColor(render, 0, 0, 0, 255);

    scope(exit) SDL_DestroyWindow(window);
    scope(exit) SDL_DestroyRenderer(render);

    // Draw the windows once before we enter the loop logic
    SDL_RenderClear(render);
    SDL_RenderPresent(render);


    loop(render);

    return 0;
}

__gshared Barrier barrier;
void init() {
    // do non-sdl init start up here


    barrier.wait(); 
}

struct Config {
    int width, height;
    bool fullscreen;
}


