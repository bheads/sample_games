module ahki.stage.manager;

private: 
import std.exception,
         std.array,
         std.range.primitives;

import ahki.stage.stage,
         ahki.sdl,
         ahki.test;

public:

struct StageStack {
private:
    IStage[] stack;

public:
    this(size_t size) {
        stack.reserve = size;
    }

    void push(IStage s) {
        enforce(stack.length <= stack.capacity, "Stage stack overflow");
        
        // Suspend the current top of the stack
        if(!empty) {
            stack.back.suspend();
        }

        // enter this new IStage
        s.enter();
        // push it
        stack ~= s;
    }

    auto pop() {
        enforce(!empty, "Stage stack under flow");
        auto s = stack.back; // remove the last item
        stack.popBack;
        // call exit on it
        s.exit();

        // trigger resume on the next item on the stack
        if(!empty) {
            stack.back.resume();
        }

        return s;
    }

    auto peek() {
        enforce(!empty, "Stage stack under flow");
        return stack.back;
    }

    auto empty() {
        return stack.empty;
    }

    void input() {
        foreach_reverse(ref s; stack) {
            s.input();
            if(!s.input_next) break;
        }
    }

    void process(double d) {
        foreach_reverse(ref s; stack) {
            s.process(d);
            if(!s.process_next) break;
        }
    }

    void render(SDL_Renderer* render) {
        // need to render bottom up, find first render index
        size_t i;
        foreach_reverse(j, ref s; stack) {
            i = j;
            if(!s.render_next) break;
        }   

        // now render each stack bottom up
        foreach(ref s; stack[i..$]) {
            s.render(render);
        }
    }
}

unittest {
    string order; 

    class TStage : IStage {
        void enter() { order ~= "a"; }
        void exit() { order ~= "b"; }

        void resume() {}
        void suspend() {}

        void input() {}
        void process(double) {}
        void render(SDL_Renderer*) {}

        bool input_next() { return false; }
        bool process_next() { return false; }
        bool render_next() { return false; }
    }

    auto s = new TStage;   
    auto stack = StageStack(5);
    stack.push(s);
    stack.pop;
    assert(order == "ab");   
}
