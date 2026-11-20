extends SceneTree

const Brick = preload("res://scripts/brick.gd")
const Bullet = preload("res://scripts/bullet.gd")
var game: Node2D
var failures := 0

func _initialize() -> void:
	run.call_deferred()

func check(condition: bool, description: String) -> void:
	if condition:
		print("PASS: ", description)
	else:
		push_error("FAIL: " + description)
		failures += 1

func frames(count: int) -> void:
	for i in range(count):
		await physics_frame

func fresh() -> void:
	game.start_game(true)
	for child in game.world.get_children():
		if child.get_script() == load("res://scripts/moose.gd"):
			child.process_mode = Node.PROCESS_MODE_DISABLED
	await frames(3)

func marked(kind: String) -> Node2D:
	for child in game.world.get_children():
		if child is Brick and child.powerup == kind:
			return child
	return null

func shoot_block(tank: Node2D, brick: Node2D) -> void:
	tank.position = brick.position + Vector2(0, -65)
	tank.turret.rotation = PI / 2
	tank.shoot()
	await frames(8)

func run() -> void:
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	await fresh()
	var counts := {"heavy": 0, "shield": 0, "speed": 0, "health": 0}
	var safe_border := true
	var hidden := true
	for child in game.world.get_children():
		if child is Brick:
			if not child.reinforced:
				hidden = hidden and child.get_child_count() == 2 and child.get_child(1).texture == load("res://assets/brick.svg")
			if not child.powerup.is_empty():
				counts[child.powerup] += 1
			if child.reinforced:
				safe_border = safe_border and child.powerup.is_empty()
	check(counts.values() == [2, 2, 2, 2] and game.remaining == 35, "R4/R9: eight hidden rewards, two of each kind, unchanged 35-block field")
	check(hidden and get_nodes_in_group("powerup_reveals").is_empty(), "R4: power-up blocks look identical to ordinary ice before impact")
	check(safe_border, "R9: no power-ups on indestructible perimeter")
	for kind in counts:
		await fresh()
		game.player_two.take_damage(60)
		await shoot_block(game.player_two, marked(kind))
		var awarded := false
		match kind:
			"heavy": awarded = game.player_two.heavy_time > 29.0
			"shield": awarded = game.player_two.shield_time > 29.0
			"speed": awarded = game.player_two.speed_time > 29.0
			"health": awarded = game.player_two.health == 75 and game.player_two.recovery_time > 0
		check(awarded and game.remaining == 34 and game.score == 100, "R7/R8: real P2 projectile awards " + kind + " exactly once and scores one block")
		check(game.player.powerup_status() == "No power-up" and game.player.health == 100, "Duel: " + kind + " belongs only to the shooter")
		check(game.hud_powerups.text.contains(game.player_two.powerup_status()), "UI2: HUD reflects " + kind)
		var reveals := get_nodes_in_group("powerup_reveals")
		check(reveals.size() == 1 and reveals[0].texture == game.Powerups.ICONS[kind], "Impact reveals the correct " + kind + " icon")
		if kind == "heavy":
			var reveal = reveals[0]
			game.pause_game()
			var reveal_age: float = reveal.age
			var reveal_position: Vector2 = reveal.position
			await frames(8)
			check(reveal.age == reveal_age and reveal.position == reveal_position, "UI3: pause freezes revealed icon animation")
			game.resume_game()
			await create_timer(1.3).timeout
			check(not is_instance_valid(reveal), "Revealed icon cleans up after its animation")
	# Health is capped and never adds lives; destroyed blocks cannot award twice.
	game.player_two.apply_powerup("health")
	check(game.player_two.health == 100 and game.player_two.lives == 3, "Heart caps health at 100 without adding a life")
	var heart := marked("health")
	heart.hit(game.player_two)
	game.player_two.take_damage(20)
	heart.hit(game.player_two)
	check(game.player_two.health == 80, "Broken block cannot grant its power-up twice")
	# Protection includes knockback and all damage sources.
	game.player_two.apply_powerup("shield")
	var before: int = game.player_two.health
	check(not game.player_two.take_moose_hit(Vector2.RIGHT), "Shield rejects moose impact")
	game.player_two.take_damage(1000)
	check(game.player_two.health == before and game.player_two.hit_push == Vector2.ZERO, "Shield prevents damage, life loss and knockback")
	game.player_two.shield_time = 0.03
	await frames(6)
	check(game.player_two.take_moose_hit(Vector2.RIGHT) and game.player_two.health == before - 20, "Damage resumes after shield expires")
	# Boost movement through the real input and physics pipeline.
	game.player_two.position = Vector2(450, 612)
	game.player_two.hit_push = Vector2.ZERO
	game.player_two.apply_powerup("speed")
	Input.action_press("p2_move_right")
	Input.action_press("p2_aim_up")
	await frames(8)
	check(is_equal_approx(game.player_two.velocity.x, 352.5) and absf(game.player_two.turret.rotation + PI / 2) < 0.01, "R5/R6: 50% speed boost with independent aiming")
	Input.action_release("p2_move_right")
	Input.action_release("p2_aim_up")
	await frames(3)
	check(game.player_two.velocity == Vector2.ZERO, "Boosted movement stops on release")
	game.player_two.position = Vector2(150, 612)
	Input.action_press("p2_move_left")
	await frames(20)
	check(game.player_two.position.x >= 135, "R9: boosted tank cannot cross perimeter")
	var wall_y: float = game.player_two.position.y
	Input.action_press("p2_move_up")
	await frames(12)
	Input.action_release("p2_move_left")
	Input.action_release("p2_move_up")
	check(game.player_two.position.y < wall_y - 20, "R8: boosted tank slides along perimeter")
	game.player_two.speed_time = 0.03
	await frames(6)
	Input.action_press("p2_move_right")
	await frames(4)
	check(is_equal_approx(game.player_two.velocity.x, 235.0), "Movement returns to baseline after boost expiry")
	Input.action_release("p2_move_right")
	# Heavy ammunition is captured when the shot is fired, with bounded splash.
	await fresh()
	await shoot_block(game.player, marked("heavy"))
	game.player.position = Vector2(904, 612)
	game.player.turret.rotation = -PI / 2
	game.player.shoot()
	var heavy_bullet: Node2D
	for child in game.world.get_children():
		if child is Bullet:
			heavy_bullet = child
	check(is_instance_valid(heavy_bullet) and heavy_bullet.heavy and game.player.heavy_time > 0, "Timed heavy power-up creates a heavy projectile")
	await frames(15)
	check(game.remaining == 31 and game.score == 400, "Heavy blast destroys only target and its two adjacent blocks")
	check(not is_instance_valid(heavy_bullet), "R3: heavy projectile removed on impact")
	game.player.position = Vector2(150, 612)
	game.player.turret.rotation = PI
	var remaining: int = game.remaining
	game.player.shoot()
	await frames(8)
	check(game.remaining == remaining and game.player_two.health == 100, "Heavy perimeter hit causes no damage to distant tank")
	game.player.heavy_time = 0.03
	game.player.position = Vector2(500, 430)
	game.player.turret.rotation = 0
	game.player.shoot()
	check(game.player.shot_is_heavy, "Shot just before expiry retains heavy payload")
	await frames(4)
	game.player.shoot()
	check(not game.player.shot_is_heavy, "Normal shots resume after heavy duration expires")
	var expiry := Bullet.new()
	expiry.heavy = true
	expiry.position = Vector2(-1000, -1000)
	expiry.origin = expiry.position
	expiry.age = 1.79
	game.world.add_child(expiry)
	await frames(4)
	check(not is_instance_valid(expiry), "R3: heavy projectile obeys lifetime expiry")
	# Combined effects, refresh, pause, reset, and eliminated players.
	for kind in counts:
		game.player.apply_powerup(kind)
	game.player.apply_powerup("heavy")
	game.player.apply_powerup("speed")
	check(game.player.heavy_time == 30.0 and game.player.speed_time == 30.0 and game.player.shield_time > 0, "Different powers combine; duplicate pickups refresh instead of stacking")
	game.pause_game()
	var shield_time: float = game.player.shield_time
	var speed_time: float = game.player.speed_time
	var recovery_time: float = game.player.recovery_time
	var heavy_time: float = game.player.heavy_time
	var shots: int = game.shots
	await frames(10)
	game.player.shoot()
	check(game.player.shield_time == shield_time and game.player.speed_time == speed_time and game.player.recovery_time == recovery_time and game.player.heavy_time == heavy_time and game.shots == shots, "UI3: pause freezes timers and blocks firing")
	game.resume_game()
	await frames(4)
	check(game.player.speed_time < speed_time, "Resume restarts effect timers")
	game.player.shield_time = 0
	game.player.take_damage(1000)
	check(game.player.powerup_status() == "No power-up" and game.player.lives == 2, "Respawn clears all power-ups")
	game.player.lives = 1
	game.player.take_damage(1000)
	game.player.apply_powerup("health")
	check(not game.player.active and game.player.health == 0, "Heart cannot revive an eliminated tank")
	game.player_two.apply_powerup("speed")
	game.restart_game()
	check(game.player.powerup_status() == "No power-up" and game.player_two.powerup_status() == "No power-up" and game.remaining == 35, "Restart resets both players and restores the field")
	game.show_menu()
	await frames(3)
	check(not is_instance_valid(game.world), "Menu cleans up power-ups with the world")
	print("POWERUP TEST FAILURES: ", failures)
	quit(1 if failures else 0)
