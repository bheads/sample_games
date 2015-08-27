module ahki.sdl;


import std.exception : enforce;
import std.format : format;
import std.conv : to;

public:



import derelict.sdl2.sdl,
	derelict.sdl2.image;


void sdl_init() {
	DerelictSDL2.load();
	enforce(SDL_Init(SDL_INIT_EVERYTHING) == 0, format("Failed to init sdl %s", SDL_GetError.to!string));

	DerelictSDL2Image.load();
	enforce(IMG_Init(IMG_INIT_PNG) == IMG_INIT_PNG, format("Failed to init sdl_image %s", IMG_GetError.to!string));
}


void sdl_quit() {

	IMG_Quit();
	SDL_Quit();
}
