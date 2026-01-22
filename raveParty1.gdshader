shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float chaos_amount : hint_range(0.0, 1.0) = 0.0;
uniform float glitch_intensity : hint_range(0.0, 1.0) = 0.0; // Новый параметр для силы глитча
uniform float scanline_intensity : hint_range(0.0, 1.0) = 0.0; // Новый параметр для полос

void fragment() {
    vec2 uv = SCREEN_UV;
    vec2 final_uv = uv;

    // --- Эффект "сдвига строк" (Glitch) ---
    // Это будет дергать случайные строки пикселей
    float y_offset = floor(uv.y * 100.0) / 100.0; // Выбираем "строку"
    float glitch_seed = fract(sin(y_offset * 12345.0 + TIME * 100.0) * 54321.0); // Случайное число для строки
    float glitch_x_offset = mix(0.0, (glitch_seed - 0.5) * 0.1, glitch_intensity); // Насколько сильно сдвигать

    final_uv.x += glitch_x_offset; // Сдвигаем UV по X

    // --- Хроматическая аберрация на весь экран ---
    float shift = chaos_amount * 0.02 * sin(TIME * 10.0);
    float r = texture(SCREEN_TEXTURE, final_uv + vec2(shift, 0.0)).r;
    float g = texture(SCREEN_TEXTURE, final_uv).g;
    float b = texture(SCREEN_TEXTURE, final_uv - vec2(shift, 0.0)).b;

    vec3 color = vec3(r, g, b);

    // --- Эффект "инверсии цветов" (вспышки) ---
    if (mod(TIME + uv.y * 0.5, 0.2) < 0.05 * chaos_amount) { // Добавил uv.y для рандома
        color = 1.0 - color;
    }

    // --- Эффект "бегущих полос" (Scanlines) ---
    float scanline = sin(uv.y * 800.0 + TIME * 50.0) * 0.02 * scanline_intensity; // Более частые и быстрые полосы
    color += scanline;

    COLOR = vec4(color, 1.0);
}