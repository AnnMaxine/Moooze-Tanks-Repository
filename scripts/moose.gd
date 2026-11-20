extends CharacterBody2D

signal emerged
signal provoked

# Moose are yielding contact hazards: walls block them, tanks never get pinned.
const SPEED := 68.0
const CHARGE_SPEED := 300.0
const CHARGE_DURATION := 2.0
const ANGER_DURATION := 0.8
const CONTACT_RADIUS := 45.0
var tanks: Array = []
var heading := Vector2.RIGHT
var emerge_delay := 0.6
var turn_timer := 3.0
var gait := 0.0
var sprite: Sprite2D
var previous_contacts: Array = []
var hazard: Area2D
var overlapping_tanks: Array = []
var charge_target: Node2D
var charge_remaining := 0.0
var anger_remaining := 0.0

func nearest_tank() -> Node2D:
	var nearest: Node2D
	var distance := INF
	for tank in tanks:
		if is_instance_valid(tank) and tank.active:
			var candidate := global_position.distance_squared_to(tank.global_position)
			if candidate < distance:
				distance = candidate
				nearest = tank
	return nearest

func hit() -> void:
	if get_tree().paused:
		return
	# Extra hits cannot hold the moose in an endless wind-up.
	if anger_remaining > 0.0 or charge_remaining > 0.0:
		return
	charge_target = nearest_tank()
	if charge_target == null:
		return
	emerge_delay = 0.0
	charge_remaining = CHARGE_DURATION
	anger_remaining = ANGER_DURATION
	provoked.emit()

func _ready() -> void:
	collision_layer = 4
	collision_mask = 1
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 21.0
	shape.shape = circle
	add_child(shape)
	# Combined with the tank's 24px circle, this preserves the 45px contact reach.
	hazard = Area2D.new()
	hazard.name = "ContactHazard"
	hazard.collision_layer = 0
	hazard.collision_mask = 2
	hazard.monitorable = false
	var trigger_shape := CollisionShape2D.new()
	trigger_shape.shape = circle.duplicate()
	hazard.add_child(trigger_shape)
	hazard.body_entered.connect(func(body):
		if body in tanks and not overlapping_tanks.has(body):
			overlapping_tanks.append(body))
	hazard.body_exited.connect(func(body): overlapping_tanks.erase(body))
	add_child(hazard)
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
	if anger_remaining > 0.0:
		anger_remaining = maxf(0.0, anger_remaining - delta)
		velocity = Vector2.ZERO
		if not is_instance_valid(charge_target) or not charge_target.active:
			charge_target = nearest_tank()
		if charge_target == null:
			anger_remaining = 0.0
			charge_remaining = 0.0
		var progress := ANGER_DURATION - anger_remaining
		sprite.position = Vector2(sin(progress * 65.0) * 5.0, cos(progress * 51.0) * 2.0)
		sprite.rotation = sin(progress * 58.0) * 0.12
		sprite.modulate = Color(1.4, 0.6, 0.45)
		if anger_remaining == 0.0:
			sprite.position = Vector2.ZERO
			sprite.rotation = 0.0
			sprite.modulate = Color.WHITE
			charge_target = nearest_tank()
		queue_redraw()
		return
	charge_remaining = maxf(0.0, charge_remaining - delta)
	if charge_remaining > 0.0:
		if not is_instance_valid(charge_target) or not charge_target.active:
			charge_target = nearest_tank()
		if charge_target == null:
			charge_remaining = 0.0
		else:
			heading = global_position.direction_to(charge_target.global_position)
	if charge_remaining == 0.0:
		charge_target = null
		turn_timer -= delta
		if turn_timer <= 0.0:
			heading = heading.rotated(0.85)
			turn_timer = 3.0
	velocity = heading * (CHARGE_SPEED if charge_remaining > 0.0 else SPEED)
	move_and_slide()
	if get_slide_collision_count() > 0:
		charge_remaining = 0.0
		charge_target = null
		heading = heading.bounce(get_slide_collision(0).get_normal()).rotated(0.25).normalized()
		turn_timer = 2.0
	var contacts: Array = []
	for tank in overlapping_tanks:
		if not is_instance_valid(tank) or not tank.active:
			continue
		if global_position.distance_to(tank.global_position) < CONTACT_RADIUS:
			charge_remaining = 0.0
			charge_target = null
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
	if anger_remaining > 0.0:
		var elapsed := ANGER_DURATION - anger_remaining
		var facing := -1.0 if sprite.flip_h else 1.0
		# Two large, continuously rising ear plumes make the warning visible at game scale.
		for ear in [Vector2(0, -12), Vector2(24, -12)]:
			for puff in range(4):
				var phase := fmod(elapsed * 1.8 + puff * 0.25, 1.0)
				var at := Vector2(ear.x * facing, ear.y) + Vector2(sin(phase * 6.0 + puff) * 6.0, -phase * 48.0)
				draw_circle(at, 6.0 + phase * 7.0, Color(0.35, 0.55, 0.68, (1.0 - phase) * 0.8))
				draw_circle(at, 4.0 + phase * 7.0, Color(0.95, 0.99, 1.0, (1.0 - phase) * 0.9))
		draw_arc(Vector2.ZERO, 36 + sin(elapsed * 20) * 3, 0, TAU, 40, Color(1, 0.2, 0.08, 0.7), 3, true)
		draw_line(Vector2(34, -43), Vector2(34, -60), Color("#ff5c35"), 5, true)
		draw_circle(Vector2(34, -35), 3, Color("#ff5c35"))
	# Alternating hoof strides below the original vector sprite.
	for i in range(4):
		var x := -18.0 + (i % 2) * 27.0
		var stride := sin(gait + (i % 2 + i / 2) * PI) * 4.0
		var start := Vector2(x, 5 + (i / 2) * 5)
		draw_line(start, start + Vector2(stride, 13), Color("#493327"), 5.0, true)
