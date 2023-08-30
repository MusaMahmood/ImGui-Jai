#import "Basic";
ImGui :: #import "ImGui-Jai";

RenderDockingInterface :: () {
    dockspace_flags : ImGui.DockNodeFlags = ImGui.DockNodeFlags.ImGuiDockNodeFlags_None;
    window_flags : ImGui.WindowFlags = ImGui.WindowFlags.ImGuiWindowFlags_MenuBar | ImGui.WindowFlags.ImGuiWindowFlags_NoDocking;
    { // opt_fullscreen = true
        viewport : ImGui.Viewport = ImGui.GetMainViewport();
        ImGui.SetNextWindowPos(viewport.Pos);
        ImGui.SetNextWindowSize(viewport.Size);
        ImGui.SetNextWindowViewport(viewport.ID_);
        ImGui.PushStyleVar(ImGui.StyleVar.ImGuiStyleVar_WindowRounding, 0.0);
        ImGui.PushStyleVar(ImGui.StyleVar.ImGuiStyleVar_WindowBorderSize, 0.0);
        window_flags |= ImGui.WindowFlags.ImGuiWindowFlags_NoTitleBar | ImGui.WindowFlags.ImGuiWindowFlags_NoCollapse | ImGui.WindowFlags.ImGuiWindowFlags_NoResize | ImGui.WindowFlags.ImGuiWindowFlags_NoMove;
        window_flags |= ImGui.WindowFlags.ImGuiWindowFlags_NoBringToFrontOnFocus | ImGui.WindowFlags.ImGuiWindowFlags_NoNavFocus;
    }
    
    if dockspace_flags & ImGui.DockNodeFlags.ImGuiDockNodeFlags_PassthruCentralNode {
        window_flags |= ImGui.WindowFlags.ImGuiWindowFlags_NoBackground;
    }

    styleval : ImGui.ImVec2 = make_vector2(0, 0);
    ImGui.PushStyleVar(ImGui.StyleVar.ImGuiStyleVar_WindowPadding, styleval);
    ImGui.Begin("DockSpace Demo", null, window_flags);
    ImGui.PopStyleVar(3);

    // Submit the DockSpace
    dock_style : ImGui.ImVec2 = make_vector2(0, 0);
    ImGui.DockSpace(ImGui.GetID("MyDockSpace"), dock_style, dockspace_flags);
    ImGui.End();
}