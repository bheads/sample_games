module ahki.loop;

import ahki.sdl;

int loop() {
	bool running = true;

	while(running) {

	}

	return 0;
}

int start(string[] args) {
	sdl_init();
	scope(exit) sdl_quit();


	return 0;
}




