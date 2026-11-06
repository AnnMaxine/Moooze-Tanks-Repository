extends SceneTree

var failures := 0
var game: Node2D

func _initialize() -> void:
	run.call_deferred()

func check(ok: bool, description: String) -> void:
	if ok:
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
	await frames(2)
	var herd := get_nodes_in_group("moose")
	check(herd.size() == 4 and get_nodes_in_group("corner_trees").is_empty(), "R9: four moose and no decorated corner trees")
	var starts: Array = []
	for moose in herd:
		starts.append(moose.position)
	check(starts[0] == game.CORNERS[0] and starts[3] == game.CORNERS[3], "R9: moose start near forest corners")
	await frames(150)
	var emerged := true
	for i in range(4):
		emerged = emerged and herd[i].position.distance_to(starts[i]) > 50
	check(emerged, "R9: all four moose emerge and roam")
	var moose = herd[0]
	for other in herd:
		other.set_physics_process(false)
	moose.set_physics_process(true)
	moose.emerge_delay = 0
	game.player.position = Vector2(500, 420)
	game.player_two.position = Vector2(800, 420)
	moose.position = game.player.position + Vector2(40, 0)
	moose.heading = Vector2.LEFT
	await frames(3)
	check(game.player.health == 80 and game.player_two.health == 100 and "P1: 80 HEALTH" in game.hud.text, "UI2/R8: actual P1 contact damages only P1 and updates HUD")
	check(game.player.position.x < 500 and game.player.hit_flash > 0, "R8: actual moose impact pushes P1 away and flashes")
	moose.position = game.player_two.position + Vector2(40, 0)
	await frames(3)
	check(game.player_two.health == 80 and "P2: 80 HEALTH" in game.hud.text, "UI2/R8: actual P2 contact updates health/HUD")
	check(game.player_two.position.x < 800 and game.player_two.hit_flash > 0, "R8: actual moose impact pushes P2 away and flashes")
	var second = herd[1]
	second.emerge_delay = 0
	second.position = game.player.position
	second.set_physics_process(true)
	await frames(3)
	check(game.player.health == 80, "R8: another moose cannot bypass shared tank cooldown")
	second.set_physics_process(false)
	moose.position = Vector2(640, 650)
	await frames(130)
	moose.position = game.player.position + Vector2(40, 0)
	await frames(3)
	check(game.player.health == 60, "R8: separated contact damages again after cooldown")
	# Hold overlap beyond cooldown to verify that contact cannot repeatedly drain health.
	for i in range(150):
		moose.position = game.player.position
		await frames(1)
	check(game.player.health == 60, "R8: sustained overlap never repeats damage without separation")
	game.pause_game()
	var at: Vector2 = moose.position
	var protection: float = game.player.moose_cooldown
	await frames(10)
	check(moose.position == at and game.player.moose_cooldown == protection and not game.player.take_moose_hit(), "UI3: pause freezes moose, cooldown and damage")
	game.resume_game()
	moose.position = Vector2(150, 420)
	moose.heading = Vector2.LEFT
	moose.turn_timer = 10
	await frames(50)
	check(moose.position.x >= 133 and moose.heading.x > 0, "R8/R9: moose bounces off reinforced perimeter")
	moose.position = Vector2(280, 350)
	moose.heading = Vector2.UP
	moose.turn_timer = 10
	await frames(40)
	check(moose.position.y >= 333 and moose.heading.y > 0, "R8: moose blocked by interior bricks and turns away")
	moose.set_physics_process(false)
	game.player.position = Vector2(500, 420)
	moose.position = Vector2(540, 420)
	Input.action_press("move_right")
	Input.action_press("p2_move_left")
	var p2: float = game.player_two.position.x
	await frames(25)
	Input.action_release("move_right")
	Input.action_release("p2_move_left")
	check(game.player.position.x > 570 and game.player_two.position.x < p2 - 60, "R5/R8: both tanks can move; moose cannot physically trap P1")
	game.player.health = 20
	game.player.moose_cooldown = 0
	game.player.take_moose_hit()
	check(game.player.lives == 2 and game.player.health == 100 and game.player.moose_cooldown > 0, "UI2: lethal moose hit respawns with protection")
	game.restart_game()
	await frames(3)
	check(get_nodes_in_group("moose").size() == 4 and game.player.moose_cooldown == 0, "UI3: restart replaces herd and clears damage cooldown")
	var contained := true
	var traveled := false
	var roaming = get_nodes_in_group("moose")[0]
	var roam_start: Vector2 = roaming.position
	for i in range(1800):
		await frames(1)
		for animal in get_nodes_in_group("moose"):
			contained = contained and Rect2(132, 173, 1016, 518).has_point(animal.position)
		traveled = traveled or roaming.position.distance_to(roam_start) > 200
	check(contained and traveled, "R9: 30-second roam stays inside perimeter and travels across arena")
	game.show_menu()
	await frames(3)
	check(get_nodes_in_group("moose").is_empty() and get_nodes_in_group("corner_trees").is_empty(), "UI1: menu removes all moose and trees")
	print("FOREST TEST FAILURES: ", failures)
	quit(1 if failures else 0)
