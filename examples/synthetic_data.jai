#import "Math";
get_sine_wave :: (freq: float64, sample_rate: float64, t: []float64, t_offset: float64, x: []float64) {
    for i: 0..t.count-1 {
        t[i] = t_offset + i / sample_rate;
        x[i] = sin_or_cos(2.0 * 3.14159268 * freq * t[i], true);
    }
}