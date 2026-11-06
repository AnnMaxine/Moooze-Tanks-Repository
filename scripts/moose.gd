extends CharacterBody2D

signal emerged

# Moose are yielding contact hazards: walls block them, tanks never get pinned.
const SPEED := 68.0
const CONTACT_RADIUS := 45.0
var tanks: Array = []
var heading := Vector2.RIGHT
var emerge_delay := 0.6
var turn_timer := 3.0
var gait := 0.0
var sprite: Sprite2D
var previous_contacts: Array = []

func _ready() -> void:
	collision_layer = 4
	collision_mask = 1
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 21.0
	shape.shape = circle
	add_child(shape)
	sprite = Sprite2D.new()
	sprite.texture = preload("res://assets/moose.svg")
	add_child(sprite)
	add_to_group("moose")

func _physics_process(delta: float) -> void:
	if emerge_delay > 0.0:
		emerge_delay -= delta
		if emerge_delay <= 0.0:
			emerged.emit()
		return
	turn_timer -= delta
	if turn_timer <= 0.0:
		heading = heading.rotated(0.85)
		turn_timer = 3.0
	velocity = heading * SPEED
	move_and_slide()
	if get_slide_collision_count() > 0:
		heading = heading.bounce(get_slide_collision(0).get_normal()).rotated(0.25).normalized()
		turn_timer = 2.0
	var contacts: Array = []
	for tank in tanks:
		if not is_instance_valid(tank) or not tank.active:
			continue
		if global_position.distance_to(tank.global_position) < CONTACT_RADIUS:
			contacts.append(tank)
			# Only fresh contact damages; sustained overlap requires separation first.
			if not previous_contacts.has(tank):
				tank.take_moose_hit(tank.global_position - global_position)
			var away: Vector2 = global_position - tank.global_position
			heading = away.normalized() if away.length_squared() > 0.01 else -heading
			turn_timer = 1.0
	previous_contacts = contacts
	gait += get_real_velocity().length() * delta * 0.12
	sprite.flip_h = heading.x < 0
	sprite.position.y = sin(gait * 2.0) * 1.5
	queue_redraw()

func _draw() -> void:
	# Alternating hoof strides below the original vector sprite.
	for i in range(4):
		var x := -18.0 + (i % 2) * 27.0
		var stride := sin(gait + (i % 2 + i / 2) * PI) * 4.0
		var start := Vector2(x, 5 + (i / 2) * 5)
		draw_line(start, start + Vector2(stride, 13), Color("#493327"), 5.0, true)
