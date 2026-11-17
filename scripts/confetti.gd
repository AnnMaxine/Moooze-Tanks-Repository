extends Control

var pieces: Array[Dictionary] = []
var age := 0.0
const COLORS := [Color("#ff709d"), Color("#ffd66b"), Color("#67c9ff"), Color("#9aff7a"), Color("#e3b7ff")]

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for i in range(100):
		pieces.append({"at": Vector2(randf_range(0, 1280), randf_range(-200, 800)), "speed": randf_range(110, 210), "angle": randf() * TAU, "color": COLORS[i % COLORS.size()]})

func _process(delta: float) -> void:
	age += delta
	for piece in pieces:
		piece.at.y += piece.speed * delta
		piece.at.x += sin(age * 2 + piece.angle) * 25 * delta
		piece.angle += delta * 2
		if piece.at.y > 810:
			piece.at.y = -15
	queue_redraw()

func _draw() -> void:
	for piece in pieces:
		draw_set_transform(piece.at, piece.angle)
		draw_rect(Rect2(-3, -6, 6, 12), piece.color)
	draw_set_transform(Vector2.ZERO)
