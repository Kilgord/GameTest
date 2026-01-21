shader_type canvas_item; // Это шейдер для 2D-объектов

uniform float hue_variation : hint_range(0.0, 1.0) = 0.0;
uniform float saturation_variation : hint_range(0.0, 2.0) = 1.0;
uniform float brightness_variation : hint_range(0.0, 2.0) = 1.0;

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
    return vec3(v, t, p); // Should not happen
}

void fragment() {
    // Получаем цвет текущего пикселя спрайта
    vec4 color = texture(TEXTURE, UV);
    
    // Преобразуем RGB в HSV
    vec3 hsv = rgb_to_hsv(color.rgb);
    
    // Применяем изменения тона, насыщенности и яркости
    hsv.r = mod(hsv.r + hue_variation, 1.0); // Изменяем тон (hue)
    hsv.g *= saturation_variation; // Изменяем насыщенность
    hsv.b *= brightness_variation; // Изменяем яркость
    
    // Преобразуем обратно в RGB
    color.rgb = hsv_to_rgb(hsv);
    
    // Применяем финальный цвет к пикселю
    COLOR = color;
}