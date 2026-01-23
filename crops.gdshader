shader_type canvas_item;

varying vec2 world_v; 

uniform vec2 player_global_pos;
uniform float interaction_radius = 250.0; // Увеличил радиус для твоего рыцаря
uniform float interaction_strength = 60.0;

void vertex() {
    // world_v теперь будет содержать координаты вершины ПРЯМО НА ЭКРАНЕ
    world_v = (CANVAS_MATRIX * MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
    
    float vertical_factor = 1.0 - UV.y;
    float base_wave = sin(TIME * 2.0 + (world_v.x * 0.05)) * 5.0;
    
    vec2 diff = world_v - player_global_pos;
    float dist = length(diff);
    
    float interaction = 0.0;
    if (dist < interaction_radius) {
        float effect = smoothstep(interaction_radius, 0.0, dist);
        // Возвращаем силу наклона
        interaction = sign(diff.x) * effect * interaction_strength;
    }
    
    VERTEX.x += (base_wave + interaction) * vertical_factor;
}

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    // Для теста: если игрок близко, подсветим синим (красный иногда сливается)
    float dist = distance(world_v, player_global_pos);
    if (dist < interaction_radius) {
        COLOR = mix(tex_color, vec4(0.0, 0.5, 1.0, 1.0), 0.4);
    } else {
        COLOR = tex_color;
    }
}