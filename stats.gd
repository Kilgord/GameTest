extends CanvasLayer

signal no_energy ()

@onready var health_bar = $HealthBar
@onready var energy_bar = $Energy

var energy_cost
var attack_cost = 10
var block_cost = 1
var run_cost = 1
 
var energy = 700:
	set(value):
		energy = value
		if energy < 1:
			emit_signal("no_energy")
			
var max_health = 100
var health:
	set(value):
		health = value
		health_bar.value = health

func _ready() -> void:
	health = max_health
	health_bar.max_value = health
	health_bar.value = health

func _process(delta: float) -> void:
	energy_bar.value = energy
	if energy < 100:
		energy += 10 * delta

func energy_consuption ():
	energy -= energy_cost
