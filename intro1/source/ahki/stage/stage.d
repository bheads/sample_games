module ahki.stage.stage;

private:
import ahki.sdl;

public:

/**
 * Game stage impl, use this for stage type duck typing
 */
interface IStage {
    void enter();
    void exit();

    void resume();
    void suspend();

    void input();
    void process(double);
    void render(SDL_Renderer*);

    bool input_next();
    bool process_next();
    bool render_next();
}
