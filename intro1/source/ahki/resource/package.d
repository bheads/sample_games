module ahki.resource;


private:

import std.variant;

import ahki.sdl:


alias ResourceRef = Algebraic!(SDL_Texture*);

struct Resource {
	uint count;
}

public:


struct ResourceManager {


}
