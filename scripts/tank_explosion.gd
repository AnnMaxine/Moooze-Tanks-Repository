extends Node2D

const DURATION := 1.0
var age := 0.0
var game: Node

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	z_index = 5

func _process(delta: float) -> void:
	if get_tree().paused and game.state == "paused":
		return
	age += delta
	if age >= DURATION:
		queue_free()
	queue_redraw()

func _draw() -> void:
	var progress := age / DURATION
	var fade := 1.0 - progress
	# Smoke, expanding fireball, shockwave and flying metal fragments.
	for i in range(7):
		var direction := Vector2.from_angle(i * TAU / 7.0)
		draw_circle(direction * progress * 38, 14 + progress * 20, Color(0.18, 0.16, 0.15, fade * 0.7))
	draw_arc(Vector2.ZERO, 20 + progress * 95, 0, TAU, 64, Color(1.0, 0.65, 0.15, fade), 4.0, true)
	draw_circle(Vector2.ZERO, 12 + sin(progress * PI) * 36, Color(1.0, 0.25, 0.03, fade))
	draw_circle(Vector2.ZERO, 6 + sin(progress * PI) * 22, Color(1.0, 0.9, 0.35, fade))
	for i in range(12):
		var direction := Vector2.from_angle(i * TAU / 12.0 + 0.2)
		var point := direction * (18 + progress * (65 + (i % 3) * 18))
		draw_line(point, point + direction.rotated(progress * 5) * 10, Color(0.3, 0.35, 0.38, fade), 5.0, true)
