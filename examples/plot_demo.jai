#load "synthetic_data.jai";

RenderPlotDemo :: (t: []float64, t_offset: float64, x: []float64, sw_freq: float64) {
    get_sine_wave(sw_freq, 250.0, t, t_offset, x);
    ImGui.Begin("Plot Demo");
    if (ImGui.ImPlot.BeginPlot("Sine Wave, y-axis only", make_vector2(-1, 250))) {
        flags := ImGui.ImPlotAxisFlags.None;
        ImGui.ImPlot.SetupAxes(null, null, flags, flags);
        ImGui.ImPlot.SetupAxisLimits(ImGui.ImAxis.ImAxis_X1, 0, cast(float64)x.count);
        ImGui.ImPlot.SetupAxisLimits(ImGui.ImAxis.ImAxis_Y1, -2, 2);
        ImGui.ImPlot.SetNextLineStyle(make_vector4(1.0, 0.5, 0.4, 1.0), 2.0);
        title: []u8 = cast,no_check([]u8)"X_data";
        ImGui.ImPlot.PlotLineJD(title.data, x.data, cast(s32)x.count, cast(float)1.0, cast(float)0.0, cast(s32)0, cast(s32)8);
        ImGui.ImPlot.EndPlot();
    }
    // TODO: Plot t, y
    if (ImGui.ImPlot.BeginPlot("Sine Wave, x and y", make_vector2(-1, 250))) {
        flags := ImGui.ImPlotAxisFlags.None;
        ImGui.ImPlot.SetupAxes(null, null, flags, flags);
        ImGui.ImPlot.SetupAxisLimits(ImGui.ImAxis.ImAxis_X1, t[0], t[t.count - 1]);
        ImGui.ImPlot.SetupAxisLimits(ImGui.ImAxis.ImAxis_Y1, -2, 2);
        ImGui.ImPlot.SetNextLineStyle(make_vector4(1.0, 0.5, 0.4, 1.0), 2.0);
        title: []u8 = cast,no_check([]u8)"X_data";
        ImGui.ImPlot.PlotLineJD(title.data, t.data, x.data, cast(s32)t.count);
        ImGui.ImPlot.EndPlot();
    }
    ImGui.End();
}