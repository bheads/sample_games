module ahki.loop;

import core.sync.barrier;
import core.time;

import std.concurrency;
import std.conv;
import std.format;
import std.string;


import dini;

import ahki.sdl,
        ahki.stage;


int loop(SDL_Window* window, SDL_Renderer* render, ref Config config, ref StageStack stageStack) {
    SDL_Event event;

    // Core game loop
    ulong lastFrame = SDL_GetPerformanceCounter(), currentFrame;
    double elapsed;

    double processLag = 0;
    double processStep = 1_000 / 20;

    uint fps, frames;
    double fpsLag = 0;

    GAME: while(!stageStack.empty) {
        ++frames; // count the frame

        // compute delta
        currentFrame = SDL_GetPerformanceCounter();
        elapsed = cast(double)((currentFrame - lastFrame)*1000) / SDL_GetPerformanceFrequency();
        lastFrame = currentFrame;
        
        // add in the update lag
        processLag += elapsed;
        fpsLag += elapsed;

        // process events
        while (SDL_PollEvent(&event)) {
            switch(event.type) {
            case SDL_QUIT:
                break GAME;
            default:
                // need to send events to the stage stack
            }
        }

        //fps
        if(fpsLag >= 1_000) {
            fps = frames;
            frames = 0;
            fpsLag = 0;
            SDL_SetWindowTitle(window, format("%s %d", config.title, fps).toStringz);
        }

        // Update stages
        while(processLag >= processStep ) {
            stageStack.process(processStep);
            processLag -= processStep;
        }

        SDL_RenderClear(render);
        stageStack.render(render);
        SDL_RenderPresent(render);
    }

    return 0;
}


int start(string[] args) {
    auto stageStack = StageStack(50);

    Config config;
    auto ini = Ini.Parse("ahki.conf");
    config.width = ini["window"].getKey("width").to!int; 
    config.height = ini["window"].getKey("height").to!int; 
    config.fullscreen = ini["window"].getKey("fullscreen").to!bool;
    config.title = ini["window"].getKey("title");


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
            (config.fullscreen ? SDL_WINDOW_FULLSCREEN : 0),
            &window, &render) == 0, format("Failed to create window due to %s", SDL_GetError().to!string));
    SDL_SetWindowTitle(window, config.title.toStringz);

    debug SDL_SetRenderDrawColor(render, 0, 0, 255, 255); // use blue for debugging
    else SDL_SetRenderDrawColor(render, 0, 0, 0, 255);

    scope(exit) SDL_DestroyWindow(window);
    scope(exit) SDL_DestroyRenderer(render);

    // Draw the windows once before we enter the loop logic
    SDL_RenderClear(render);
    SDL_RenderPresent(render);

    // Run the game loop
    return loop(window, render, config, stageStack);
}

__gshared Barrier barrier;
void init() {
    // do non-sdl init start up here


    barrier.wait(); 
}

struct Config {
    int width, height;
    bool fullscreen;
    string title;
}


