extends CharacterBody2D

signal fired(origin: Vector2, muzzle: Vector2, direction: Vector2)
signal vitals_changed
signal moose_hit
signal exploded
signal lives_depleted
const MAX_HEALTH := 100
const STARTING_LIVES := 3
const Powerups = preload("res://scripts/powerups.gd")
var heavy_ammo := 0
var shield_time := 0.0
var speed_time := 0.0
var recovery_time := 0.0
var shot_is_heavy := false
var respawn_protection := 0.0
var player_number := 1
var health := MAX_HEALTH
var lives := STARTING_LIVES
var spawn_position := Vector2.ZERO
const SPEED := 235.0
const FIRE_INTERVAL := 0.22
var turret: Node2D
var chassis: Sprite2D
var cooldown := 0.0
var active := true
var shot_flash := 0.0
const MOOSE_DAMAGE := 20
const MOOSE_COOLDOWN := 2.0
var moose_cooldown := 0.0
const HIT_PUSH_SPEED := 520.0
const HIT_PUSH_DECELERATION := 1800.0
const HIT_FLASH_TIME := 0.3
var hit_push := Vector2.ZERO
var hit_flash := 0.0

func _ready() -> void:
	# Keep playable tanks visible when moving through decorative corner foliage.
	z_index = 3
	spawn_position = position
	collision_layer = 2
	collision_mask = 1
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	var collision := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 24.0
	collision.shape = circle
	add_child(collision)
	chassis = Sprite2D.new()
	chassis.texture = preload("res://assets/tank.svg")
	add_child(chassis)
	if player_number == 2:
		chassis.modulate = Color(1.8, 0.65, 1.0)
	turret = Node2D.new()
	add_child(turret)
	var sprite := Sprite2D.new()
	sprite.texture = preload("res://assets/turret.svg")
	sprite.position = Vector2(12, 0)
	turret.add_child(sprite)
	if player_number == 2:
		sprite.modulate = Color(1.8, 0.65, 1.0)

func _physics_process(delta: float) -> void:
	if not active:
		velocity = Vector2.ZERO
		return
	moose_cooldown = maxf(0.0, moose_cooldown - delta)
	respawn_protection = maxf(0.0, respawn_protection - delta)
	shield_time = maxf(0.0, shield_time - delta)
	speed_time = maxf(0.0, speed_time - delta)
	recovery_time = maxf(0.0, recovery_time - delta)
	var prefix := "p2_" if player_number == 2 else ""
	var movement := Input.get_vector(prefix + "move_left", prefix + "move_right", prefix + "move_up", prefix + "move_down")
	velocity = movement * SPEED * (Powerups.SPEED_MULTIPLIER if speed_time > 0.0 else 1.0) + hit_push
	move_and_slide()
	hit_push = hit_push.move_toward(Vector2.ZERO, HIT_PUSH_DECELERATION * delta)
	hit_flash = maxf(0.0, hit_flash - delta)
	modulate = Color.WHITE.lerp(Color(1.8, 0.55, 0.35), hit_flash / HIT_FLASH_TIME)
	if movement.length_squared() > 0.0:
		chassis.rotation = lerp_angle(chassis.rotation, movement.angle() + PI / 2.0, minf(delta * 14.0, 1.0))
	if player_number == 1:
		turret.rotation = (get_global_mouse_position() - global_position).angle()
	else:
		var aim := Input.get_vector("p2_aim_left", "p2_aim_right", "p2_aim_up", "p2_aim_down")
		if aim != Vector2.ZERO:
			turret.rotation = aim.angle()
	cooldown = maxf(0.0, cooldown - delta)
	shot_flash = maxf(0.0, shot_flash - delta)
	if Input.is_action_pressed(prefix + "fire") and cooldown <= 0.0:
		shoot()
	queue_redraw()

# Shared by every moose, independently for each tank. Existing damage API stays intact.
func take_moose_hit(away_from_moose: Vector2 = Vector2.ZERO) -> bool:
	if moose_cooldown > 0.0 or shield_time > 0.0 or not active or get_tree().paused:
		return false
	moose_cooldown = MOOSE_COOLDOWN
	var previous_lives := lives
	take_damage(MOOSE_DAMAGE)
	# Never carry an impact impulse to a respawn or eliminated tank.
	if active and lives == previous_lives:
		var direction := away_from_moose.normalized()
		if direction == Vector2.ZERO:
			direction = Vector2.LEFT
		hit_push = direction * HIT_PUSH_SPEED
		hit_flash = HIT_FLASH_TIME
		modulate = Color(1.8, 0.55, 0.35)
		queue_redraw()
	moose_hit.emit()
	return true

func take_projectile_hit(amount: int) -> void:
	if respawn_protection > 0.0 or shield_time > 0.0 or not active or get_tree().paused:
		return
	var previous_lives := lives
	take_damage(amount)
	if active and lives == previous_lives:
		hit_flash = HIT_FLASH_TIME
		modulate = Color(1.8, 0.55, 0.35)
		queue_redraw()

func take_damage(amount: int) -> void:
	if amount <= 0 or shield_time > 0.0 or not active or not is_inside_tree() or get_tree().paused:
		return
	health = maxi(0, health - amount)
	if health == 0:
		clear_powerups()
		exploded.emit()
		lives -= 1
		velocity = Vector2.ZERO
		hit_push = Vector2.ZERO
		hit_flash = 0.0
		modulate = Color.WHITE
		cooldown = 0.0
		shot_flash = 0.0
		if lives > 0:
			respawn_protection = 2.0
			moose_cooldown = MOOSE_COOLDOWN
			position = spawn_position
			health = MAX_HEALTH
		else:
			active = false
	vitals_changed.emit()
	if lives == 0:
		lives_depleted.emit()

func shoot() -> void:
	if not active or get_tree().paused:
		return
	cooldown = FIRE_INTERVAL
	shot_flash = 0.06
	shot_is_heavy = heavy_ammo > 0
	if shot_is_heavy:
		heavy_ammo -= 1
	var direction := Vector2.RIGHT.rotated(turret.rotation)
	fired.emit(global_position, global_position + direction * 50.0, direction)
	vitals_changed.emit()

func apply_powerup(kind: String) -> void:
	if not active or get_tree().paused:
		return
	match kind:
		"heavy": heavy_ammo = Powerups.HEAVY_SHOTS
		"shield": shield_time = Powerups.DURATION
		"speed": speed_time = Powerups.DURATION
		"health":
			health = mini(MAX_HEALTH, health + Powerups.HEAL_AMOUNT)
			recovery_time = 2.0
		_: return
	vitals_changed.emit()
	queue_redraw()

func clear_powerups() -> void:
	heavy_ammo = 0
	shield_time = 0.0
	speed_time = 0.0
	recovery_time = 0.0
	shot_is_heavy = false

func powerup_status() -> String:
	var effects: PackedStringArray = []
	if heavy_ammo > 0:
		effects.append("HEAVY %d" % heavy_ammo)
	if shield_time > 0.0:
		effects.append("SHIELD %ds" % ceili(shield_time))
	if speed_time > 0.0:
		effects.append("SPEED %ds" % ceili(speed_time))
	if recovery_time > 0.0:
		effects.append("HEALED")
	return " / ".join(effects) if not effects.is_empty() else "No power-up"

func _draw() -> void:
	if shield_time > 0.0:
		draw_circle(Vector2.ZERO, 38, Color(0.15, 0.75, 1.0, 0.2))
		draw_arc(Vector2.ZERO, 38, 0, TAU, 64, Powerups.COLORS.shield, 3.0, true)
	if heavy_ammo > 0 and is_instance_valid(turret):
		var barrel := Vector2.RIGHT.rotated(turret.rotation)
		draw_line(barrel * 8, barrel * 44, Color(1.0, 0.55, 0.12, 0.65), 13.0, true)
		draw_arc(Vector2.ZERO, 29, 0, TAU, 48, Powerups.COLORS.heavy, 3.0, true)
	if speed_time > 0.0 and is_instance_valid(chassis):
		var forward := Vector2.UP.rotated(chassis.rotation)
		var side := forward.orthogonal()
		for distance in [34.0, 44.0, 54.0]:
			var tail: Vector2 = -forward * distance
			draw_line(tail + side * 15, tail + forward * 8, Powerups.COLORS.speed, 3.0, true)
			draw_line(tail - side * 15, tail + forward * 8, Powerups.COLORS.speed, 3.0, true)
	if recovery_time > 0.0:
		draw_arc(Vector2.ZERO, 42, 0, TAU, 48, Powerups.COLORS.health, 3.0, true)
		draw_texture(Powerups.ICONS.health, Vector2(-16, -66 - (2.0 - recovery_time) * 6))
	if hit_flash > 0.0:
		var progress := 1.0 - hit_flash / HIT_FLASH_TIME
		var impact_color := Color(1.0, 0.45, 0.12, 1.0 - progress)
		draw_arc(Vector2.ZERO, 36 + progress * 24, 0, TAU, 48, impact_color, 4.0)
		for i in range(8):
			var ray := Vector2.from_angle(i * TAU / 8.0)
			draw_line(ray * (40 + progress * 16), ray * (52 + progress * 24), impact_color, 3.0, true)
	if moose_cooldown > 0.0 or respawn_protection > 0.0:
		draw_arc(Vector2.ZERO, 34, 0, TAU, 48, Color("#ffbf69"), 3.0)
	draw_arc(Vector2.ZERO, 31, 0, TAU, 48, Color(0.15, 0.4, 0.65, 0.3), 1.5)
	if shot_flash > 0.0 and is_instance_valid(turret):
		var direction := Vector2.RIGHT.rotated(turret.rotation)
		draw_circle(direction * 54, 8, Color("#eefaff"))
