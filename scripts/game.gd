extends Node2D

const Brick = preload("res://scripts/brick.gd")
const Player = preload("res://scripts/player.gd")
const Moose = preload("res://scripts/moose.gd")
const CORNERS := [Vector2(166, 206), Vector2(1114, 206), Vector2(166, 662), Vector2(1114, 662)]
const Bullet = preload("res://scripts/bullet.gd")
const MINT := Color("#a6dfff")
const CREAM := Color("#eef8ff")
var sound: Node
var world: Node2D
var player: CharacterBody2D
var player_two: CharacterBody2D
var local_coop := false
var ui: CanvasLayer
var panel: Control
var hud: Label
var hud_root: Panel
var hud_stats: Label
var pause_button: Button
var remaining := 0
var total := 0
var shots := 0
var score := 0
var elapsed := 0.0
var state := "menu"
var particles: Array[Dictionary] = []
var finish_pending := false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	sound = preload("res://scripts/sound.gd").new()
	add_child(sound)
	configure_input()
	build_theme()
	ui = CanvasLayer.new()
	add_child(ui)
	show_menu()

func configure_input() -> void:
	var mappings := {"move_up": KEY_W, "move_down": KEY_S, "move_left": KEY_A, "move_right": KEY_D, "p2_move_up": KEY_UP, "p2_move_down": KEY_DOWN, "p2_move_left": KEY_LEFT, "p2_move_right": KEY_RIGHT, "p2_aim_up": KEY_T, "p2_aim_down": KEY_G, "p2_aim_left": KEY_F, "p2_aim_right": KEY_H, "p2_fire": KEY_J}
	for action in mappings:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
			var event := InputEventKey.new()
			event.physical_keycode = mappings[action]
			InputMap.action_add_event(action, event)
	if not InputMap.has_action("fire"):
		InputMap.add_action("fire")
		var mouse := InputEventMouseButton.new()
		mouse.button_index = MOUSE_BUTTON_LEFT
		InputMap.action_add_event("fire", mouse)

func build_theme() -> void:
	var theme := Theme.new()
	theme.default_font_size = 19
	theme.set_color("font_color", "Label", CREAM)
	for key in ["normal", "hover", "pressed", "focus", "disabled"]:
		var style := StyleBoxFlat.new()
		style.bg_color = Color("#214d50") if key == "normal" else Color("#356e71")
		if key == "disabled":
			style.bg_color = Color("#19272f")
		style.set_corner_radius_all(8)
		style.content_margin_left = 22
		style.content_margin_right = 22
		style.content_margin_top = 12
		style.content_margin_bottom = 12
		style.set_border_width_all(1)
		style.border_color = Color("#ffd890") if key == "focus" else Color("#668fab")
		if key == "focus":
			style.bg_color = Color.TRANSPARENT
			style.set_border_width_all(3)
		theme.set_stylebox(key, "Button", style)
	theme.set_color("font_color", "Button", CREAM)
	theme.set_color("font_disabled_color", "Button", Color("#73827e"))
	ThemeDB.fallback_font_size = 19
	# Store a shared theme for each independent overlay.
	set_meta("ui_theme", theme)

func clear_panel() -> void:
	if is_instance_valid(panel):
		ui.remove_child(panel)
		panel.queue_free()
		panel = null

func overlay() -> VBoxContainer:
	clear_panel()
	panel = Control.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel.theme = get_meta("ui_theme")
	ui.add_child(panel)
	var shade := ColorRect.new()
	shade.color = Color(0.025, 0.07, 0.09, 0.78)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel.add_child(shade)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel.add_child(center)
	var card := PanelContainer.new()
	card.add_theme_stylebox_override("panel", card_style())
	center.add_child(card)
	var box := VBoxContainer.new()
	box.custom_minimum_size.x = 560
	box.add_theme_constant_override("separation", 12)
	card.add_child(box)
	return box

func card_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#102f3c")
	style.border_color = Color("#7fb9c9")
	style.set_border_width_all(2)
	style.set_corner_radius_all(18)
	style.content_margin_left = 32
	style.content_margin_right = 32
	style.content_margin_top = 24
	style.content_margin_bottom = 24
	style.shadow_color = Color(0, 0, 0, 0.3)
	style.shadow_size = 12
	return style

func logo_in(box: VBoxContainer, height: float) -> void:
	var logo := TextureRect.new()
	logo.texture = preload("res://assets/menu_logo.png")
	logo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	logo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	logo.custom_minimum_size.y = height
	logo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(logo)

func label_in(box: VBoxContainer, text: String, size: int = 20, color: Color = CREAM) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	box.add_child(label)
	return label

func button_in(box: VBoxContainer, text: String, callback: Callable, disabled: bool = false) -> Button:
	var button := Button.new()
	button.text = text
	button.disabled = disabled
	button.custom_minimum_size.y = 48
	if callback.is_valid():
		button.pressed.connect(func(): sound.play("click"))
		button.pressed.connect(callback)
	box.add_child(button)
	return button

func show_menu() -> void:
	get_tree().paused = false
	state = "menu"
	sound.stop_gameplay()
	if is_instance_valid(world):
		remove_child(world)
		world.queue_free()
	if is_instance_valid(hud_root):
		hud_root.queue_free()
	if is_instance_valid(pause_button):
		pause_button.queue_free()
	particles.clear()
	var box := overlay()
	logo_in(box, 118)
	label_in(box, "MOOOZE TANKS", 46)
	label_in(box, "Snowy trails. Big antlers. Tiny tanks.", 19, MINT)
	button_in(box, "Play", show_play).grab_focus()
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	box.add_child(row)
	for entry in [["Controls", show_controls], ["Help", show_help]]:
		var column := VBoxContainer.new()
		column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(column)
		button_in(column, entry[0], entry[1])
	button_in(box, "Sound", show_sound)
	button_in(box, "Credits", show_credits)
	button_in(box, "Exit", func(): get_tree().quit())
	label_in(box, "A winter field adventure for one or two players", 16, MINT)
	queue_redraw()

func show_play() -> void:
	var box := overlay()
	label_in(box, "CHOOSE YOUR CREW", 36, MINT)
	label_in(box, "Clear the icy field alone or together.", 20)
	button_in(box, "Solo Practice", start_game).grab_focus()
	button_in(box, "Local Co-op / 2 Players", start_game.bind(true))
	label_in(box, "Local co-op shares one score and one objective.", 17, MINT)
	var host := button_in(box, "Host Game - Coming with multiplayer", Callable(), true)
	host.tooltip_text = "Server integration is not available yet."
	button_in(box, "Join Game - Coming with multiplayer", Callable(), true)
	button_in(box, "Main Menu", show_menu)

func show_controls() -> void:
	var box := overlay()
	label_in(box, "CONTROLS", 40, MINT)
	label_in(box, "PLAYER 1  /  BLUE TANK", 23, Color("#8fd5ff"))
	label_in(box, "Move: W A S D\nAim: Mouse\nShoot: Left mouse button (hold to repeat)", 21)
	label_in(box, "PLAYER 2  /  PURPLE TANK", 23, Color("#e3b7ff"))
	label_in(box, "Move: Arrow keys\nAim: T up / F left / G down / H right\nShoot: J (hold to repeat)", 21)
	label_in(box, "Combine aim keys for diagonals; release to keep your aim.\nMove and aim independently. Esc pauses or resumes.", 17, MINT)
	button_in(box, "Help", show_help)
	button_in(box, "Main Menu", show_menu).grab_focus()

func show_sound() -> void:
	var box := overlay()
	label_in(box, "SOUND", 40, MINT)
	var value_label := label_in(box, "Volume: %d%% (0 = mute)" % roundi(sound.volume * 100), 23)
	var slider := HSlider.new()
	slider.min_value = 0
	slider.max_value = 100
	slider.step = 1
	slider.value = sound.volume * 100
	slider.custom_minimum_size = Vector2(490, 40)
	slider.value_changed.connect(func(value: float):
		sound.set_volume(value / 100.0)
		value_label.text = "Volume: %d%% (0 = mute)" % roundi(value)
	)
	box.add_child(slider)
	button_in(box, "Back to Menu", show_menu)
	slider.grab_focus()

func show_help() -> void:
	var box := overlay()
	label_in(box, "FIELD GUIDE", 40, MINT)
	label_in(box, "CLEAR THE WINTER FIELD", 22, Color("#ffd890"))
	label_in(box, "Shoot all 35 icy bricks to win. Each earns 100 points.\nThe forest border is indestructible. Slide along walls to pass.\nIn local co-op, both players share the score and victory.", 19)
	label_in(box, "KEEP YOUR CREW ROLLING", 22, Color("#ffd890"))
	label_in(box, "Each tank starts with 100 health and 3 lives.\nAt zero health, lose a life and respawn at full health.\nA tank with no lives is out; a surviving teammate can continue.\nThe round ends in defeat when no tanks have lives left.", 19)
	label_in(box, "GIVE THE MOOSE SOME ROOM", 22, Color("#ffd890"))
	label_in(box, "Roaming moose turn and bounce off obstacles.\nContact deals 20 damage and knocks your tank back.\nA gold ring means 2 seconds of protection; separate to re-hit.\nMoose yield to tanks. Snowballs pass through moose.\nTanks cannot damage each other.", 19)
	button_in(box, "Controls", show_controls)
	button_in(box, "Main Menu", show_menu).grab_focus()

func show_credits() -> void:
	var box := overlay()
	label_in(box, "JDAT STUDIOS", 40, MINT)
	label_in(box, "@Studio - Client-Side Development\nOlaniyi Tolulope - Product Design & Business Analysis\nAnna-Marie Oyemiren - Game Design & Project Operations", 19)
	label_in(box, "Server-side project partner: Ctrl-Alt-Elite\nOriginal vector artwork created for Moooze Tanks.", 17)
	button_in(box, "Back to Menu", show_menu).grab_focus()

func restart_game() -> void:
	start_game(local_coop)

func start_game(coop: bool = false) -> void:
	sound.stop_gameplay()
	local_coop = coop
	player_two = null
	get_tree().paused = false
	clear_panel()
	if is_instance_valid(world):
		remove_child(world)
		world.queue_free()
	if is_instance_valid(hud_root):
		hud_root.queue_free()
	if is_instance_valid(pause_button):
		pause_button.queue_free()
	world = Node2D.new()
	world.process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(world)
	remaining = 0
	score = 0
	shots = 0
	elapsed = 0.0
	finish_pending = false
	particles.clear()
	for col in range(24):
		add_brick(Vector2(88 + col * 48, 132), true)
		add_brick(Vector2(88 + col * 48, 732), true)
	for row in range(1, 15):
		add_brick(Vector2(88, 132 + row * 40), true)
		add_brick(Vector2(1192, 132 + row * 40), true)
	for cluster in [Vector2(280, 252), Vector2(760, 252), Vector2(424, 492), Vector2(904, 492)]:
		for col in range(4):
			for row in range(2):
				add_brick(cluster + Vector2(col * 48, row * 40), false)
	for row in range(3):
		add_brick(Vector2(616, 292 + row * 40), false)
	total = remaining
	player = Player.new()
	player.position = Vector2(208, 612)
	player.moose_hit.connect(sound.play_moose_contact)
	player.exploded.connect(func(): sound.play("explosion"))
	player.fired.connect(spawn_bullet)
	player.vitals_changed.connect(update_hud)
	player.lives_depleted.connect(on_lives_depleted)
	world.add_child(player)
	if local_coop:
		player_two = Player.new()
		player_two.player_number = 2
		player_two.position = Vector2(1072, 612)
		player_two.moose_hit.connect(sound.play_moose_contact)
		player_two.exploded.connect(func(): sound.play("explosion"))
		player_two.fired.connect(spawn_bullet)
		player_two.vitals_changed.connect(update_hud)
		player_two.lives_depleted.connect(on_lives_depleted)
		world.add_child(player_two)
	# Moose start near the forest corners.
	for i in range(CORNERS.size()):
		var moose := Moose.new()
		moose.position = CORNERS[i]
		moose.heading = Vector2.RIGHT if i % 2 == 0 else Vector2.LEFT
		moose.emerge_delay = 0.6 + i * 0.25
		moose.tanks = [player]
		if local_coop:
			moose.tanks.append(player_two)
		moose.emerged.connect(func(): sound.play("moose_roar"))
		world.add_child(moose)
	build_hud()
	state = "playing"
	update_hud()
	queue_redraw()

func build_hud() -> void:
	hud_root = Panel.new()
	hud_root.name = "GameplayHUD"
	hud_root.position = Vector2(64, 8)
	hud_root.size = Vector2(1152, 78)
	hud_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud_root.add_theme_stylebox_override("panel", card_style())
	ui.add_child(hud_root)
	var logo := TextureRect.new()
	logo.name = "MooseTankLogo"
	logo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	logo.texture = preload("res://assets/hud_logo.png")
	logo.position = Vector2(8, 1)
	logo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	logo.size = Vector2(90, 60)
	logo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	logo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud_root.add_child(logo)
	var brand := Label.new()
	brand.text = "MOOOZE TANKS"
	brand.position = Vector2(7, 58)
	brand.add_theme_font_size_override("font_size", 12)
	hud_root.add_child(brand)
	hud = Label.new()
	hud.position = Vector2(118, 10)
	hud.add_theme_font_size_override("font_size", 20)
	hud.add_theme_color_override("font_color", CREAM)
	hud_root.add_child(hud)
	hud_stats = Label.new()
	hud_stats.position = Vector2(550, 12)
	hud_stats.add_theme_font_size_override("font_size", 17)
	hud_stats.add_theme_color_override("font_color", Color("#ffd890"))
	hud_root.add_child(hud_stats)
	pause_button = Button.new()
	pause_button.theme = get_meta("ui_theme")
	pause_button.focus_mode = Control.FOCUS_NONE
	pause_button.text = "Pause  [Esc]"
	pause_button.position = Vector2(970, 14)
	pause_button.size = Vector2(164, 48)
	pause_button.pressed.connect(func(): sound.play("click"))
	pause_button.pressed.connect(pause_game)
	hud_root.add_child(pause_button)

func add_brick(at: Vector2, reinforced: bool) -> void:
	var brick := Brick.new()
	brick.position = at
	brick.reinforced = reinforced
	brick.destroyed.connect(on_brick_destroyed)
	world.add_child(brick)
	if not reinforced:
		remaining += 1

func spawn_bullet(origin: Vector2, muzzle: Vector2, direction: Vector2) -> void:
	if state != "playing":
		return
	var bullet := Bullet.new()
	bullet.position = muzzle
	bullet.origin = origin
	bullet.direction = direction
	bullet.impact = burst
	world.add_child(bullet)
	shots += 1
	sound.play("shoot")

func on_brick_destroyed(at: Vector2) -> void:
	sound.play("brick")
	remaining -= 1
	score += 100
	burst(at)
	if remaining == 0 and not finish_pending:
		finish_pending = true
		finish_game.call_deferred()

func burst(at: Vector2) -> void:
	for i in range(12):
		particles.append({"position": at, "velocity": Vector2.from_angle(randf() * TAU) * randf_range(50, 190), "life": 0.5, "size": randf_range(2, 6)})

func _process(delta: float) -> void:
	var moving := false
	var idle := false
	if state == "playing":
		for tank in [player, player_two]:
			if is_instance_valid(tank) and tank.active:
				var driving: bool = tank.get_real_velocity().length_squared() > 1.0
				moving = moving or driving
				idle = idle or not driving
	sound.update_ambience(state == "playing", moving, idle, state == "paused")
	if state == "playing":
		elapsed += delta
		update_hud()
		for particle in particles:
			particle.position += particle.velocity * delta
			particle.life -= delta
		particles = particles.filter(func(p): return p.life > 0)
	queue_redraw()

func update_hud() -> void:
	if is_instance_valid(hud):
		hud.text = "PLAYER 1 / SOLO\n%d HEALTH     %d LIVES" % [player.health, player.lives]
		if local_coop and is_instance_valid(player_two):
			hud.text = "P1: %d HEALTH / %d LIVES\nP2: %d HEALTH / %d LIVES" % [player.health, player.lives, player_two.health, player_two.lives]
		hud_stats.text = "%s: %04d POINTS   |   %02d:%02d\nICE LEFT: %d / %d   |   SHOTS: %d" % ["TEAM SCORE" if local_coop else "SCORE", score, int(elapsed) / 60, int(elapsed) % 60, remaining, total, shots]

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		if state == "playing":
			pause_game()
		elif state == "paused":
			resume_game()
		get_viewport().set_input_as_handled()

func pause_game() -> void:
	if state != "playing":
		return
	state = "paused"
	sound.stop_gameplay()
	sound.voices.music.stream_paused = true
	get_tree().paused = true
	var box := overlay()
	label_in(box, "TAKE A BREATHER", 42, MINT)
	label_in(box, "Your field will be right here.", 20)
	button_in(box, "Resume", resume_game).grab_focus()
	button_in(box, "Restart", restart_game)
	button_in(box, "Main Menu", show_menu)

func resume_game() -> void:
	clear_panel()
	state = "playing"
	get_tree().paused = false
	if remaining == 0:
		finish_game.call_deferred()

func on_lives_depleted() -> void:
	if local_coop and (player.active or player_two.active):
		return
	if state != "playing":
		return
	state = "results"
	get_tree().paused = true
	var box := overlay()
	label_in(box, "GAME OVER", 48, MINT)
	label_in(box, "Winner: None - no lives remaining", 23, Color("#ffd890"))
	results_summary(box)
	button_in(box, "Play Again", restart_game).grab_focus()
	button_in(box, "Main Menu", show_menu)

func finish_game() -> void:
	if state != "playing":
		return
	sound.stop_gameplay()
	sound.play("victory")
	update_hud()
	state = "results"
	get_tree().paused = true
	var box := overlay()
	label_in(box, "FIELD CLEARED", 48, MINT)
	label_in(box, "Winner: Team P1 + P2" if local_coop else "Winner: Player 1", 25, Color("#ffd890"))
	label_in(box, "Local co-op complete" if local_coop else "Solo practice complete", 19, MINT)
	results_summary(box)
	button_in(box, "Play Again", restart_game).grab_focus()
	button_in(box, "Main Menu", show_menu)

func results_summary(box: VBoxContainer) -> void:
	label_in(box, "%s: %d points" % ["Shared team score" if local_coop else "Score", score], 26)
	label_in(box, "%d / %d bricks cleared   |   %d shots fired\nTime played: %02d:%02d" % [total - remaining, total, shots, int(elapsed) / 60, int(elapsed) % 60], 21)
	label_in(box, "Player 1: %d health / %d lives" % [player.health, player.lives], 20, Color("#8fd5ff"))
	if local_coop:
		label_in(box, "Player 2: %d health / %d lives" % [player_two.health, player_two.lives], 20, Color("#e3b7ff"))

# Pure background drawing: no nodes, collisions, input, or gameplay state.
func draw_holiday_border() -> void:
	var festive := [Color("#ef5360"), Color("#62d29a"), Color("#ffd66b"), Color("#67c9ff"), Color("#f5fbff")]
	# Lights frame the field without covering the HUD or brick perimeter.
	for strip_y in [99.0, 773.0]:
		for i in range(47):
			var at := Vector2(65 + i * 25, strip_y + sin(i * 0.65) * 3)
			if i < 46:
				draw_line(at, Vector2(at.x + 25, strip_y + sin((i + 1) * 0.65) * 3), Color("#3e806b"), 2, true)
			var glow: Color = festive[i % 5]
			glow.a = 0.12
			draw_circle(at + Vector2(0, 4), 7, glow)
			draw_circle(at + Vector2(0, 4), 2.6, festive[i % 5])

func _draw() -> void:
	draw_rect(Rect2(0, 0, 1280, 800), Color("#193b50"))
	# Snow drifts and wind lines are decorative; collision geometry is unchanged.
	draw_rect(Rect2(62, 106, 1156, 648), Color("#d5e8f1"))
	for i in range(28):
		var at := Vector2(120 + (i * 173) % 1040, 165 + (i * 97) % 520)
		draw_circle(at, 22 + i % 5 * 9, Color(0.94, 0.98, 1.0, 0.28))
		draw_line(at + Vector2(-25, 13), at + Vector2(34, 9), Color(0.65, 0.79, 0.87, 0.24), 1.0, true)
	var snow_time := Time.get_ticks_msec() / 1000.0
	for i in range(170):
		var at := Vector2(70 + fposmod(i * 137 + sin(snow_time * 0.8 + i) * 22, 1136), 112 + fposmod(i * 83 + snow_time * (38 + i % 9 * 4), 634))
		var radius := 2.0 + (i % 4) * 0.6
		# Blue edging keeps white snow readable against the pale snowfield.
		draw_circle(at + Vector2(0, 0.8), radius + 0.9, Color(0.28, 0.49, 0.66, 0.5))
		draw_circle(at, radius, Color(1.0, 1.0, 1.0, 0.95))
		if i % 5 == 0:
			draw_line(at - Vector2(5, 0), at + Vector2(5, 0), Color.WHITE, 1.2, true)
			draw_line(at - Vector2(0, 5), at + Vector2(0, 5), Color.WHITE, 1.2, true)
	draw_rect(Rect2(62, 106, 1156, 648), Color("#91bcd3"), false, 2)
	draw_holiday_border()
	draw_line(Vector2(64, 91), Vector2(1216, 91), MINT, 2)
	for particle in particles:
		var tint := Color(0.98, 1.0, 1.0, particle.life * 2)
		draw_circle(particle.position, particle.size, tint)
		var shard := PackedVector2Array([particle.position + Vector2(0, -particle.size * 2), particle.position + Vector2(particle.size, 0), particle.position + Vector2(0, particle.size), particle.position + Vector2(-particle.size, 0)])
		draw_colored_polygon(shard, Color(0.35, 0.72, 0.95, particle.life * 1.5))
	if state == "playing":
		var mouse := get_global_mouse_position()
		var reticle := Color("#285879")
		draw_arc(mouse, 10, 0, TAU, 24, reticle, 1.5)
		draw_line(mouse - Vector2(16, 0), mouse - Vector2(6, 0), reticle)
		draw_line(mouse + Vector2(6, 0), mouse + Vector2(16, 0), reticle)
		draw_line(mouse - Vector2(0, 16), mouse - Vector2(0, 6), reticle)
		draw_line(mouse + Vector2(0, 6), mouse + Vector2(0, 16), reticle)
