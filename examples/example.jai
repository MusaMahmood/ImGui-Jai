#load "imgui_sdl_gl.jai";
#load "styles.jai";
#load "fonts.jai";
#load "dockspace.jai";
#load "plot_demo.jai";
#import "String";
//#import "Debug";


main :: () {
    print("\n\n------------ PROGRAM_OUTPUT ------------\n\n");
    SDL_Init(SDL_INIT_VIDEO);

    window := SDL_CreateWindow("ImGui SDL2+OpenGL example", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, 1280, 720, SDL_WINDOW_OPENGL|SDL_WINDOW_RESIZABLE);

    // Check that the window was successfully created
    if window == null {
        // In the case that the window could not be made...
        log_error("Could not create window: %", to_string(SDL_GetError()));
        exit(1);
    }

    log("ImGui (docking) % ", to_string(ImGui.GetVersion()));

    //SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 3);
    //SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 3);
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, xx SDL_GL_CONTEXT_PROFILE_CORE);

    gl_context := SDL_GL_CreateContext(window);
    if !gl_context {
        log_error("Could not create OpenGL context: %", to_string(SDL_GetError()));
        exit(1);
    }

    gl_load(*gl, SDL_GL_GetProcAddress);

    imgui_context := ImGui.CreateContext();

    io := ImGui.GetIO();
    io.ConfigFlags_ |= ImGui.ConfigFlags.DockingEnable;
    io.ConfigFlags_ |= ImGui.ConfigFlags.ViewportsEnable;
    
    // Setup style
    ImGui.StyleColorsDark();
    style : *ImGui.Style = ImGui.GetStyle();
    ImGui_SetStyle_EnemyMouse(style);
    if io.ConfigFlags_ & ImGui.ConfigFlags.ViewportsEnable {
        style.WindowRounding = 0.0;
        style.Colors[ImGui.Col.WindowBg].w = 1.0;
    }

    // Setup ImGui binding
    ImGui_ImplSdl_Init(window);

    // TODO: Load fonts and upload to GL?
    all_font_files := FindAllFonts("../fonts");
    all_fonts : [..]*ImGui.ImFont; array_resize(*all_fonts, all_font_files.count);
    current_font_index := -1;
    for ff : 0..all_font_files.count-1 {
        str_len := all_font_files[ff].count;
        // Allocate a buffer for the string & copy
        font_path_cstr : [..]u8; array_resize(*font_path_cstr, str_len+1);
        memcpy(font_path_cstr.data, all_font_files[ff].data, str_len);
        font_path_cstr[str_len] = 0; // null-terminate
        print("Loading font: %\n", all_font_files[ff]);
        all_fonts[ff] = ImGui.IO.Fonts.AddFontFromFileTTF(io.Fonts, font_path_cstr.data, 18.0);
        if wildcard_match(all_font_files[ff], "*JetBrainsMono-Bold.ttf*") {
            current_font_index = ff;
        }
    }

    show_demo_window := true;
    clear_color := make_vector4(0.45, 0.55, 0.60, 1.00);

    // Need to share context to ImPlot:
    // imcontext : *ImPlot.ImGuiContext = cast(*ImPlot.ImGuiContext)ImGui.GetCurrentContext();
    // ImPlot.SetImGuiContext(imcontext);
    x_data: [..]float64; array_resize(*x_data, 2000);
    t_data: [..]float64; array_resize(*t_data, 2000);
    defer array_free(x_data);
    // TODO: Put these in a struct, I'm too lazy
    freq : float64 = 2.0;
    sampling_rate :: 250.0;
    t_offset : float64 = 0.0;

    // Main loop
    done := false;
    while !done {
        t_offset += io.DeltaTime;
        // You can read the io.WantCaptureMouse, io.WantCaptureKeyboard flags to tell if dear imgui wants to use your inputs.
        // - When io.WantCaptureMouse is true, do not dispatch mouse input data to your main application.
        // - When io.WantCaptureKeyboard is true, do not dispatch keyboard input data to your main application.
        // Generally you may always pass all inputs to dear imgui, and hide them from your application based on those two flags.
        event: SDL_Event;
        while SDL_PollEvent(*event) {
            ImGui_ImplSdl_ProcessEvent(*event);
            if event.type == SDL_QUIT   done = true;
            if event.type == SDL_WINDOWEVENT && event.window.event == SDL_WINDOWEVENT_CLOSE && event.window.windowID == SDL_GetWindowID(window) {
                done = true;
            }
        }
        ImGui_ImplSdl_NewFrame(window);
        // Start the frame. This call will update the io.WantCaptureMouse, io.WantCaptureKeyboard flag that you can use to dispatch inputs (or not) to your application.
        ImGui.NewFrame();
        // NOTE: UI content begins
        if current_font_index >= 0 { ImGui.PushFont(all_fonts[current_font_index]); }
        RenderDockingInterface();
        // 3. Show the ImGui demo window. Most of the sample code is in ImGui.ShowDemoWindow().
        if show_demo_window {
            // ImGui.SetNextWindowPos(*make_vector2(650, 20), ImGui.Cond.FirstUseEver, *make_vector2(0,0)); // Normally user code doesn't need/want to call this because positions are saved in .ini file anyway. Here we just want to make the demo initial state a bit more friendly!
            ImGui.ShowDemoWindow(*show_demo_window);
            ImGui.ImPlot.CreateContext();
            ImGui.ImPlot.ShowDemoWindow(*show_demo_window);
            RenderPlotDemo(t_data, t_offset, x_data, freq);
            ImGui.ImPlot.DestroyContext();
        }
        // NOTE: UI content ends
        if current_font_index >= 0 { ImGui.PopFont(); }

        if ImGui.GetMouseCursor() == {
            case .Arrow;         SDL_SetCursor(cursor_arrow);
            case .TextInput;     SDL_SetCursor(cursor_text_input);
            case .Hand;          SDL_SetCursor(cursor_move);
            case .ResizeNS;      SDL_SetCursor(cursor_resize_ns);
            case .ResizeEW;      SDL_SetCursor(cursor_resize_ew);
            case .ResizeNESW;    SDL_SetCursor(cursor_resize_nesw);
            case .ResizeNWSE;    SDL_SetCursor(cursor_resize_nwse);
        }

        // Rendering
        ImGui.Render();
        glViewport(0, 0, xx io.DisplaySize.x, xx io.DisplaySize.y);
        glClearColor(clear_color.x, clear_color.y, clear_color.z, clear_color.w);
        glClear(GL_COLOR_BUFFER_BIT);
        ImGui_ImplSdl_RenderDrawLists(ImGui.GetDrawData());
        SDL_GL_SwapWindow(window);
    }
    array_free(x_data);

    // Cleanup
    ImGui_ImplSdl_Shutdown();
    ImGui.DestroyContext(imgui_context);
    SDL_GL_DeleteContext(gl_context);
    SDL_DestroyWindow(window);
    SDL_Quit();
}

