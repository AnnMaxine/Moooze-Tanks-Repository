extends CharacterBody2D

signal fired(origin: Vector2, muzzle: Vector2, direction: Vector2)
signal vitals_changed
signal moose_hit
signal exploded
signal lives_depleted
signal damaged
const MAX_HEALTH := 100
const STARTING_LIVES := 3
const Powerups = preload("res://scripts/powerups.gd")
var heavy_time := 0.0
var shield_time := 0.0
var speed_time := 0.0
var shot_is_heavy := false
var respawn_protection := 0.0
var player_number := 1
var user_id := "":
	set(value):
		user_id = value
		update_vitals_display()
var vitals_display: Control
var user_id_label: Label
var health_bar: ProgressBar
var lives_label: Label
const VITALS_FADE_DISTANCE := 100.0
const VITALS_FADED_ALPHA := 0.35
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
	build_vitals_display()
	vitals_changed.connect(update_vitals_display)
	update_vitals_display()

func build_vitals_display() -> void:
	vitals_display = Control.new()
	vitals_display.name = "TankVitals"
	vitals_display.position = Vector2(-96, -76)
	vitals_display.z_index = 10
	vitals_display.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(vitals_display)
	var plate := Control.new()
	plate.name = "CompactVitals"
	plate.position = Vector2(42, 0)
	plate.size = Vector2(144, 48)
	vitals_display.add_child(plate)
	user_id_label = Label.new()
	user_id_label.position = Vector2(0, 0)
	user_id_label.size = Vector2(144, 23)
	user_id_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	user_id_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	user_id_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	user_id_label.add_theme_font_size_override("font_size", 16)
	user_id_label.add_theme_color_override("font_color", Color("#eefaff"))
	user_id_label.add_theme_color_override("font_outline_color", Color("#082641"))
	user_id_label.add_theme_constant_override("outline_size", 4)
	plate.add_child(user_id_label)
	user_id_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	health_bar = ProgressBar.new()
	health_bar.name = "HealthBar"
	health_bar.position = Vector2(0, 24)
	health_bar.size = Vector2(144, 20)
	health_bar.max_value = MAX_HEALTH
	health_bar.show_percentage = false
	health_bar.add_theme_font_size_override("font_size", 12)
	var background := StyleBoxFlat.new()
	background.bg_color = Color("#061e2d")
	background.border_color = Color("#8eefff")
	background.set_border_width_all(2)
	health_bar.add_theme_stylebox_override("background", background)
	var fill := StyleBoxTexture.new()
	fill.texture = preload("res://assets/vitals_fill.svg")
	health_bar.add_theme_stylebox_override("fill", fill)
	health_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	plate.add_child(health_bar)
	# Apply after styles/percentage so the default theme minimum cannot enlarge it.
	health_bar.size = Vector2(144, 20)
	var heart := TextureRect.new()
	heart.name = "LivesHeart"
	heart.texture = preload("res://assets/vitals_heart.svg")
	heart.position = Vector2(0, 15)
	heart.size = Vector2(48, 46)
	heart.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	heart.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	vitals_display.add_child(heart)
	lives_label = Label.new()
	lives_label.position = Vector2(8, 20)
	lives_label.size = Vector2(32, 27)
	lives_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lives_label.add_theme_font_size_override("font_size", 22)
	lives_label.add_theme_color_override("font_outline_color", Color("#102f3c"))
	lives_label.add_theme_constant_override("outline_size", 5)
	vitals_display.add_child(lives_label)
	for control in vitals_display.get_children():
		control.mouse_filter = Control.MOUSE_FILTER_IGNORE

func update_vitals_display() -> void:
	if not is_instance_valid(health_bar):
		return
	# Local fallback only; the server can assign user_id without a networking contract.
	user_id_label.text = user_id if not user_id.is_empty() else "Player %d" % player_number
	user_id_label.tooltip_text = user_id_label.text
	health_bar.value = health
	lives_label.text = str(lives)

func update_vitals_opacity(delta: float) -> void:
	var nearby := false
	if get_real_velocity().length_squared() > 1.0:
		for body in get_parent().get_children():
			var is_brick: bool = body.get_script() == preload("res://scripts/brick.gd") and not body.broken
			if (is_brick or body.is_in_group("moose")) and body is Node2D:
				if global_position.distance_squared_to(body.global_position) < VITALS_FADE_DISTANCE * VITALS_FADE_DISTANCE:
					nearby = true
					break
	var target := VITALS_FADED_ALPHA if nearby else 1.0
	vitals_display.modulate.a = move_toward(vitals_display.modulate.a, target, delta * 5.0)

func _physics_process(delta: float) -> void:
	if not active:
		velocity = Vector2.ZERO
		return
	moose_cooldown = maxf(0.0, moose_cooldown - delta)
	respawn_protection = maxf(0.0, respawn_protection - delta)
	heavy_time = maxf(0.0, heavy_time - delta)
	shield_time = maxf(0.0, shield_time - delta)
	speed_time = maxf(0.0, speed_time - delta)
	var prefix := "p2_" if player_number == 2 else ""
	var movement := Input.get_vector(prefix + "move_left", prefix + "move_right", prefix + "move_up", prefix + "move_down")
	velocity = movement * SPEED * (Powerups.SPEED_MULTIPLIER if speed_time > 0.0 else 1.0) + hit_push
	move_and_slide()
	update_vitals_opacity(delta)
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

func take_projectile_hit(amount: int, heavy: bool = false) -> void:
	if respawn_protection > 0.0 or not active or get_tree().paused:
		return
	if shield_time > 0.0:
		if heavy:
			shield_time = maxf(0.0, shield_time - Powerups.HEAVY_SHIELD_PENALTY)
			queue_redraw()
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
	damaged.emit()
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
	shot_is_heavy = heavy_time > 0.0
	var direction := Vector2.RIGHT.rotated(turret.rotation)
	fired.emit(global_position, global_position + direction * 50.0, direction)
	vitals_changed.emit()

func apply_powerup(kind: String) -> void:
	if not active or get_tree().paused:
		return
	match kind:
		"heavy": heavy_time = Powerups.DURATION
		"shield": shield_time = Powerups.SHIELD_DURATION
		"speed": speed_time = Powerups.DURATION
		_: return
	vitals_changed.emit()
	queue_redraw()

func clear_powerups() -> void:
	heavy_time = 0.0
	shield_time = 0.0
	speed_time = 0.0
	shot_is_heavy = false

func powerup_status() -> String:
	var effects: PackedStringArray = []
	if heavy_time > 0.0:
		effects.append("HEAVY %ds" % ceili(heavy_time))
	if shield_time > 0.0:
		effects.append("SHIELD %ds" % ceili(shield_time))
	if speed_time > 0.0:
		effects.append("SPEED %ds" % ceili(speed_time))
	return " / ".join(effects) if not effects.is_empty() else "No power-up"

func _draw() -> void:
	var times := [heavy_time, shield_time, speed_time]
	var active_effects := 0
	for time in times:
		if time > 0.0:
			active_effects += 1
	var slot := 0
	for index in range(times.size()):
		if times[index] <= 0.0:
			continue
		var kind: String = Powerups.TYPES[index]
		var center := Vector2((slot - (active_effects - 1) * 0.5) * 32.0, 62)
		draw_circle(center, 14, Color("#082641"))
		draw_arc(center, 13, -PI / 2, -PI / 2 + TAU * times[index] / (Powerups.SHIELD_DURATION if kind == "shield" else Powerups.DURATION), 48, Powerups.COLORS[kind], 3, true)
		draw_texture_rect(Powerups.ICONS[kind], Rect2(center - Vector2(8, 8), Vector2(16, 16)), false)
		var seconds := str(ceili(times[index]))
		var font := ThemeDB.fallback_font
		draw_string(font, center + Vector2(-font.get_string_size(seconds, HORIZONTAL_ALIGNMENT_LEFT, -1, 11).x / 2, 26), seconds, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color.WHITE)
		slot += 1
	if shield_time > 0.0:
		var shield_outline := PackedVector2Array([
			Vector2(0, -48), Vector2(42, -32), Vector2(40, 12),
			Vector2(30, 33), Vector2(0, 52), Vector2(-30, 33),
			Vector2(-40, 12), Vector2(-42, -32), Vector2(0, -48),
		])
		draw_polyline(shield_outline, Powerups.COLORS.shield, 3.5, true)
	if heavy_time > 0.0 and is_instance_valid(turret):
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
