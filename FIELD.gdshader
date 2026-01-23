shader_type canvas_item;

// Для передачи координат из vertex в fragment
varying vec2 world_v;

uniform vec2 player_global_pos;
uniform float radius = 150.0;
uniform float wave_strength = 30.0; // Теперь можно больше - у нас много вершин!

void vertex() {
    // Получаем экранные координаты вершины
    world_v = (CANVAS_MATRIX * MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
    
    // Расстояние до игрока
    float dist = distance(world_v, player_global_pos);
    
    // Эффект только если игрок близко
    if (dist < radius) {
        // Сила эффекта (1.0 рядом с игроком, 0.0 на границе)
        float strength = 1.0 - smoothstep(0.0, radius, dist);
        
        // Ветер + эффект от игрока
        float wave = sin(TIME * 3.0 + UV.x * 10.0) * 5.0; // Небольшой ветер
        
        // Эффект "убегания" от игрока
        vec2 dir = normalize(world_v - player_global_pos);
        wave += dir.x * strength * wave_strength;
        
        // Верхняя часть колышется сильнее
        float vertical_factor = 1.0 - UV.y;
        
        // Двигаем вершину!
        VERTEX.x += wave * vertical_factor;
    }
}

void fragment() {
    // Просто рисуем текстуру
    COLOR = texture(TEXTURE, UV);
    
    // Для отладки можно добавить подсветку
    float dist = distance(world_v, player_global_pos);
    if (dist < radius) {
        float glow = 1.0 - smoothstep(0.0, radius, dist);
        COLOR.rgb = mix(COLOR.rgb, vec3(0.5, 0.8, 1.0), glow * 0.3);
    }
}