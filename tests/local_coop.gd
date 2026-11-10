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
	game.start_game(true)
	await frames(3)
	check(game.player_two != null and game.player_two.chassis.modulate != game.player.chassis.modulate, "R1/R2: distinct second tank")
	var p1: Vector2 = game.player.position
	var p2: Vector2 = game.player_two.position
	Input.action_press("p2_move_left")
	Input.action_press("p2_aim_up")
	await frames(10)
	Input.action_release("p2_move_left")
	Input.action_release("p2_aim_up")
	await frames(2)
	check(game.player.position == p1 and game.player_two.position.x < p2.x, "R5: P2 input affects only P2")
	check(absf(angle_difference(game.player_two.turret.rotation, -PI / 2)) < 0.01, "R6: P2 aims independently while moving")
	p2 = game.player_two.position
	var angle: float = game.player_two.turret.rotation
	Input.action_press("move_right")
	var mouse := InputEventMouseMotion.new()
	mouse.position = Vector2(900, 300)
	Input.parse_input_event(mouse)
	await frames(10)
	Input.action_release("move_right")
	check(game.player.position.x > p1.x and game.player_two.position == p2 and game.player_two.turret.rotation == angle, "R5/R6: P1 movement/mouse cannot control P2; P2 release stops and holds aim")
	game.player.cooldown = 0
	game.player_two.cooldown = 0
	var before: int = game.shots
	Input.action_press("fire")
	Input.action_press("p2_fire")
	await frames(2)
	Input.action_release("fire")
	Input.action_release("p2_fire")
	check(game.shots == before + 2, "R7: both fire independently in the same frame")
	game.player_two.position = Vector2(760, 400)
	game.player_two.turret.rotation = -PI / 2
	game.player_two.shoot()
	await frames(20)
	check(game.score >= 100 and game.remaining < 35, "R3/R7/R8: P2 shot destroys ice and awards shared points")
	game.player_two.position = Vector2(1130, 612)
	Input.action_press("p2_move_right")
	await frames(30)
	Input.action_release("p2_move_right")
	check(game.player_two.position.x <= 1145, "R8/R9: P2 cannot escape perimeter")
	p2 = game.player_two.position
	Input.action_press("p2_move_up")
	await frames(10)
	Input.action_release("p2_move_up")
	check(game.player_two.position.y < p2.y, "R8: P2 slides along wall")
	game.pause_game()
	p1 = game.player.position
	p2 = game.player_two.position
	before = game.shots
	Input.action_press("move_right")
	Input.action_press("p2_move_left")
	Input.action_press("p2_fire")
	await frames(5)
	Input.action_release("move_right")
	Input.action_release("p2_move_left")
	Input.action_release("p2_fire")
	check(game.player.position == p1 and game.player_two.position == p2 and game.shots == before, "UI3: pause freezes both players")
	game.resume_game()
	game.player_two.take_damage(25)
	check(game.player.health == 100 and game.player_two.health == 75 and "P2: 75 HEALTH" in game.hud.text, "UI2: independent health and live HUD")
	game.player_two.take_damage(100)
	check(game.player_two.position == Vector2(1072, 612) and game.player_two.lives == 2 and game.player.lives == 3, "UI2: P2 respawns independently")
	game.player_two.take_damage(100)
	game.player_two.take_damage(100)
	check(game.state == "playing" and game.player.active and not game.player_two.active, "UI4: survivor continues after teammate loses all lives")
	for i in range(3):
		game.player.take_damage(100)
	await create_timer(1.2).timeout
	check(game.state == "results" and paused, "UI4: game over when both are eliminated")
	game.restart_game()
	await frames(3)
	check(game.local_coop and game.player_two.lives == 3 and game.player.lives == 3, "UI3/UI4: restart preserves co-op and resets both")
	for child in game.world.get_children():
		if child.get_script() == load("res://scripts/brick.gd") and not child.reinforced:
			child.hit()
	await frames(3)
	check(game.state == "results" and game.score == 3500, "UI4: shared field completion")
	game.show_menu()
	await frames(3)
	game.start_game()
	await frames(3)
	check(not game.local_coop and game.player_two == null, "UI1: Solo Practice remains single-player")
	print("CO-OP TEST FAILURES: ", failures)
	quit(1 if failures else 0)
