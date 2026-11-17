extends StaticBody2D

signal destroyed(at: Vector2)
signal powerup_released(kind: String, recipient: Node)
var reinforced := false
var broken := false
var powerup := ""

func _ready() -> void:
	collision_layer = 1
	collision_mask = 0
	var shape := CollisionShape2D.new()
	var box := RectangleShape2D.new()
	box.size = Vector2(48, 40)
	shape.shape = box
	add_child(shape)
	var sprite := Sprite2D.new()
	sprite.texture = preload("res://assets/brick.svg")
	if reinforced:
		sprite.texture = preload("res://assets/forest_tree.svg")
		sprite.position.y = -8.0
	add_child(sprite)

func hit(recipient: Node = null) -> void:
	if reinforced or broken:
		return
	broken = true
	hide()
	set_deferred("collision_layer", 0)
	if not powerup.is_empty() and is_instance_valid(recipient):
		powerup_released.emit(powerup, recipient)
	destroyed.emit(global_position)
	queue_free()
