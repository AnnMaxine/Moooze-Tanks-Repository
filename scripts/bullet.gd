extends Node2D

const Brick = preload("res://scripts/brick.gd")
const SPEED := 780.0
const LIFETIME := 1.8
var direction := Vector2.RIGHT
var age := 0.0
var origin := Vector2.ZERO
var first_step := true
var impact: Callable
var shooter: Node
var heavy := false
var heavy_impact: Callable
var hits_tanks := false

func _ready() -> void:
	var sprite := Sprite2D.new()
	sprite.texture = preload("res://assets/bullet.svg")
	if heavy:
		sprite.scale = Vector2.ONE * 1.6
		sprite.modulate = Color("#ffae45")
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
	# Duel shots hit opposing tanks; the shooter is excluded from the whole sweep.
	var query := PhysicsRayQueryParameters2D.create(start, next, 1 | 4 | (2 if hits_tanks else 0))
	if is_instance_valid(shooter):
		query.exclude = [shooter.get_rid()]
	query.hit_from_inside = true
	var result := get_world_2d().direct_space_state.intersect_ray(query)
	if not result.is_empty():
		if result.collider is Brick:
			var brick = result.collider
			var can_blast: bool = heavy and not brick.reinforced and not brick.broken
			var center: Vector2 = brick.global_position
			brick.hit(shooter if is_instance_valid(shooter) else null)
			if can_blast and heavy_impact.is_valid():
				heavy_impact.call(center, shooter if is_instance_valid(shooter) else null)
		elif hits_tanks and result.collider.has_method("take_projectile_hit"):
			result.collider.take_projectile_hit(40 if heavy else 20)
		elif result.collider.has_method("hit"):
			result.collider.hit()
		if impact.is_valid():
			impact.call(result.position)
		queue_free()
		return
	global_position = next
