extends SceneTree

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

func run() -> void:
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	check(game.state == "menu", "Main menu loads")
	game.show_help()
	game.show_credits()
	game.start_game()
	await frames(3)
	check(game.remaining == 35, "R4/R9: field contains 35 destructible bricks")
	check(game.player.get_child_count() == 3, "R1/R2: collision, chassis and separate turret exist")
	var start: Vector2 = game.player.position
	Input.action_press("move_right")
	await frames(20)
	Input.action_release("move_right")
	await frames(2)
	check(game.player.position.x > start.x + 30, "R5: movement responds to input")
	var stopped: Vector2 = game.player.position
	await frames(5)
	check(game.player.position.distance_to(stopped) < 0.1, "R5: movement stops on release")
	var chassis_before: float = game.player.chassis.rotation
	var mouse := InputEventMouseMotion.new()
	mouse.position = Vector2(900, 400)
	Input.parse_input_event(mouse)
	await frames(3)
	var expected_angle: float = (game.player.get_global_mouse_position() - game.player.global_position).angle()
	check(absf(angle_difference(game.player.turret.rotation, expected_angle)) < 0.01 and game.player.chassis.rotation == chassis_before, "R2/R6: turret follows mouse without rotating chassis")
	check(game.player.turret.global_position.distance_to(game.player.global_position) < 0.01, "R6: turret remains attached")
	var shot_count: int = game.shots
	Input.action_press("fire")
	await frames(2)
	Input.action_release("fire")
	check(game.shots > shot_count, "R7: fire input spawns a projectile")
	game.player.position = Vector2(150, 612)
	Input.action_press("move_left")
	await frames(40)
	Input.action_release("move_left")
	check(game.player.position.x >= 135, "R8/R9: perimeter blocks tank")
	Input.action_press("move_up")
	var along: float = game.player.position.y
	await frames(20)
	Input.action_release("move_up")
	check(game.player.position.y < along - 30, "R8: tank slides along wall without sticking")
	game.player.position = Vector2(280, 400)
	game.spawn_bullet(Vector2(280, 400), Vector2(280, 350), Vector2.UP)
	await frames(20)
	check(game.remaining == 34 and game.score == 100, "R3/R7/R8: projectile destroys brick and awards score")
	# A bullet starting beyond the near face must still hit that face.
	game.spawn_bullet(Vector2(328, 335), Vector2(328, 285), Vector2.UP)
	await frames(5)
	check(game.remaining == 33, "R7/R8: muzzle overlap cannot bypass brick")
	game.player.position = Vector2(328, 350)
	Input.action_press("move_up")
	await frames(13)
	Input.action_release("move_up")
	check(game.player.position.y < 312, "R8: destroyed brick no longer obstructs movement")
	var count_before: int = game.remaining
	game.spawn_bullet(Vector2(150, 612), Vector2(100, 612), Vector2.LEFT)
	await frames(5)
	check(game.remaining == count_before, "R9: reinforced boundary survives projectile")
	var lifetime_bullet = load("res://scripts/bullet.gd").new()
	lifetime_bullet.position = Vector2(-1000, -1000)
	lifetime_bullet.origin = lifetime_bullet.position
	game.world.add_child(lifetime_bullet)
	await create_timer(2.0).timeout
	check(not is_instance_valid(lifetime_bullet), "R3: projectile lifetime cleanup")
	game.pause_game()
	var paused_time: float = game.elapsed
	var paused_pos: Vector2 = game.player.position
	Input.action_press("move_right")
	await frames(5)
	Input.action_release("move_right")
	check(paused and game.elapsed == paused_time and game.player.position == paused_pos, "UI3: pause freezes gameplay and timer")
	game.resume_game()
	check(not paused and game.state == "playing", "UI3: resume restores gameplay")
	for child in game.world.get_children():
		if child.get_script() == load("res://scripts/brick.gd") and not child.reinforced:
			child.hit()
	await frames(3)
	check(game.remaining == 0 and game.state == "results" and game.score == 3500, "UI2/UI4: full clear produces correct results")
	game.start_game()
	await frames(3)
	check(game.remaining == 35 and game.score == 0 and not paused, "Replay resets field and score")
	check(game.player.health == 100 and game.player.lives == 3 and "100 HEALTH     3 LIVES" in game.hud.text and "SCORE: 0000 POINTS" in game.hud_stats.text, "UI2: initial HUD shows accurate vitals and score")
	game.player.take_damage(25)
	check(game.player.health == 75 and game.player.lives == 3 and "75 HEALTH" in game.hud.text, "UI2: damage updates HUD immediately")
	game.player.take_damage(0)
	game.player.take_damage(-25)
	check(game.player.health == 75, "Invalid damage ignored")
	game.pause_game()
	game.player.take_damage(100)
	check(game.player.health == 75 and game.player.lives == 3, "UI3: paused damage ignored")
	game.resume_game()
	game.player.position = Vector2(500, 600)
	game.score = 100
	game.player.take_damage(1000)
	check(game.player.health == 100 and game.player.lives == 2 and game.player.position == Vector2(208, 612) and game.player.velocity == Vector2.ZERO and game.score == 100 and game.remaining == 35, "Lethal damage loses one life and respawns preserving field/score")
	check("100 HEALTH     2 LIVES" in game.hud.text and game.state == "playing", "UI2: respawn updates HUD")
	Input.action_press("move_right")
	await frames(5)
	Input.action_release("move_right")
	check(game.player.position.x > 208, "R5: respawned player moves")
	game.player.take_damage(100)
	check(game.player.lives == 1 and game.player.health == 100, "Second death leaves one life")
	game.player.take_damage(100)
	check(game.player.lives == 0 and game.player.health == 0 and not game.player.active and paused and game.state == "results", "UI4: final death ends play")
	check("0 HEALTH     0 LIVES" in game.hud.text and game.panel.find_children("*", "Label", true, false)[0].text == "GAME OVER", "UI2/UI4: final HUD and game-over message")
	game.player.take_damage(100)
	check(game.player.lives == 0, "Post-game damage ignored")
	game.start_game()
	await frames(3)
	check(game.player.health == 100 and game.player.lives == 3 and game.player.active and not paused and game.score == 0, "Replay resets health/lives")
	game.show_menu()
	await frames(3)
	check(game.state == "menu" and not is_instance_valid(game.world), "Return to menu cleans world")
	print("SMOKE TEST FAILURES: ", failures)
	quit(1 if failures else 0)
