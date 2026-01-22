shader_type canvas_item;

uniform float hue_variation : hint_range(0.0, 1.0) = 0.0;
uniform float saturation_variation : hint_range(0.0, 2.0) = 1.0;
uniform float brightness_variation : hint_range(0.0, 2.0) = 1.0;

uniform float pixel_stretch : hint_range(0.0, 1.0) = 0.0; // Новый параметр!
uniform float pixel_stretch_direction : hint_range(0.0, 1.0) = 0.0; // 0=horizontal, 1=vertical

vec3 rgb_to_hsv(vec3 color) {
    float max_val = max(color.r, max(color.g, color.b));
    float min_val = min(color.r, min(color.g, color.b));
    float delta = max_val - min_val;

    float h = 0.0;
    if (delta == 0.0) {
        h = 0.0;
    } else if (max_val == color.r) {
        h = mod((color.g - color.b) / delta, 6.0);
    } else if (max_val == color.g) {
        h = ((color.b - color.r) / delta) + 2.0;
    } else {
        h = ((color.r - color.g) / delta) + 4.0;
    }
    h = h / 6.0;

    float s = (max_val == 0.0) ? 0.0 : (delta / max_val);
    float v = max_val;

    return vec3(h, s, v);
}

vec3 hsv_to_rgb(vec3 color) {
    float h = color.r;
    float s = color.g;
    float v = color.b;

    float i = floor(h * 6.0);
    float f = h * 6.0 - i;
    float p = v * (1.0 - s);
    float q = v * (1.0 - f * s);
    float t = v * (1.0 - (1.0 - f) * s);

    if (i == 0.0) return vec3(v, t, p);
    if (i == 1.0) return vec3(q, v, p);
    if (i == 2.0) return vec3(p, v, t);
    if (i == 3.0) return vec3(p, q, v);
    if (i == 4.0) return vec3(t, p, v);
    if (i == 5.0) return vec3(v, p, q);
    return vec3(v, t, p);
}

void fragment() {
    // Рассчитываем силу расслоения (аберрации)
    float aberration = pixel_stretch * 0.05; 
    
    vec2 uv_r = UV + vec2(aberration, 0.0);
    vec2 uv_b = UV - vec2(aberration, 0.0);
    
    // Берем разные каналы цвета с разным смещением
    float r = texture(TEXTURE, uv_r).r;
    float g = texture(TEXTURE, UV).g;
    float b = texture(TEXTURE, uv_b).b;
    float a = texture(TEXTURE, UV).a;

    vec4 color = vec4(r, g, b, a);
    
    // Твой старый код HSV
    vec3 hsv = rgb_to_hsv(color.rgb);
    hsv.r = mod(hsv.r + hue_variation, 1.0);
    hsv.g *= saturation_variation;
    hsv.b *= brightness_variation;
    
    color.rgb = hsv_to_rgb(hsv);
    COLOR = color;
}