extends Sprite2D

var age := 0.0
const DURATION := 1.2

func _ready() -> void:
	z_index = 5
	scale = Vector2.ONE * 1.25
	add_to_group("powerup_reveals")

func _process(delta: float) -> void:
	age += delta
	position.y -= 24.0 * delta
	modulate.a = clampf((DURATION - age) / 0.4, 0.0, 1.0)
	if age >= DURATION:
		queue_free()
