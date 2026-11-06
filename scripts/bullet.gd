extends Node2D

const SPEED := 780.0
const LIFETIME := 1.8
var direction := Vector2.RIGHT
var age := 0.0
var origin := Vector2.ZERO
var first_step := true
var impact: Callable

func _ready() -> void:
	var sprite := Sprite2D.new()
	sprite.texture = preload("res://assets/bullet.svg")
	add_child(sprite)
	rotation = direction.angle()

func _physics_process(delta: float) -> void:
	age += delta
	if age >= LIFETIME:
		queue_free()
		return
	var next := global_position + direction * SPEED * delta
	# Sweep from the turret on the first frame, so a muzzle inside a wall
	# cannot shoot through it. The tank is on a different collision layer.
	var start := origin if first_step else global_position
	first_step = false
	var query := PhysicsRayQueryParameters2D.create(start, next, 1)
	var result := get_world_2d().direct_space_state.intersect_ray(query)
	if not result.is_empty():
		if result.collider.has_method("hit"):
			result.collider.hit()
		if impact.is_valid():
			impact.call(result.position)
		queue_free()
		return
	global_position = next
