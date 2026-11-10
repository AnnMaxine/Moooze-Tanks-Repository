extends SceneTree

var game: Node2D
var failures := 0

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
	game.start_game(true)
	await frames(3)
	for animal in get_nodes_in_group("moose"):
		animal.set_physics_process(false)
	for tank in [game.player, game.player_two]:
		var shape := CircleShape2D.new()
		shape.radius = 24
		var query := PhysicsShapeQueryParameters2D.new()
		query.shape = shape
		query.transform = Transform2D(0, tank.position)
		query.collision_mask = 1
		check(tank.get_world_2d().direct_space_state.intersect_shape(query).is_empty(), "Tank spawn is clear of cover and perimeter")
	var directions := {"move_up": Vector2.UP, "move_left": Vector2.LEFT, "move_down": Vector2.DOWN, "move_right": Vector2.RIGHT}
	for action in directions:
		game.player.position = Vector2(500, 420)
		Input.action_press(action)
		await frames(12)
		check(game.player.velocity.is_equal_approx(directions[action] * game.player.SPEED), "WASD direction: " + action)
		Input.action_release(action)
		await frames(2)
		check(game.player.velocity == Vector2.ZERO, "Release stops: " + action)
	game.player.position = Vector2(500, 420)
	Input.action_press("move_up")
	Input.action_press("move_right")
	await frames(15)
	check(is_equal_approx(game.player.velocity.length(), game.player.SPEED), "Diagonal movement has no speed boost")
	check(absf(angle_difference(game.player.chassis.rotation, PI / 4)) < 0.1, "Chassis smoothly faces diagonal travel")
	Input.action_release("move_up")
	Input.action_release("move_right")
	await frames(2)
	var start: float = game.elapsed
	await create_timer(0.25).timeout
	check(game.elapsed > start + 0.15, "Match clock advances during play")
	game.pause_game()
	start = game.elapsed
	await create_timer(0.2).timeout
	check(game.elapsed == start, "Pause freezes match clock")
	game.resume_game()
	game.finish_game()
	start = game.elapsed
	await create_timer(0.2).timeout
	check(game.elapsed == start, "Results freeze match clock")
	game.restart_game()
	check(game.elapsed == 0, "Restart resets match clock")
	await frames(3)
	for animal in get_nodes_in_group("moose"):
		animal.set_physics_process(false)
	var moose = get_nodes_in_group("moose")[0]
	check(moose.hazard is Area2D and moose.hazard.collision_layer == 0 and moose.hazard.collision_mask == 2, "Area2D hazard monitors only tanks without adding a solid barrier")
	game.player.position = Vector2(500, 420)
	moose.position = Vector2(540, 420)
	moose.hazard.monitoring = false
	moose.emerge_delay = 0
	moose.heading = Vector2.LEFT
	await frames(3)
	moose.set_physics_process(true)
	await frames(5)
	check(game.player.health == 100, "Disabling Area2D monitoring prevents environmental contact damage")
	moose.hazard.monitoring = true
	await frames(5)
	check(game.player.health == 80 and game.player.hit_flash > 0, "Area2D entry triggers existing damage and impact feedback")
	moose.position = Vector2(800, 420)
	await frames(5)
	check(not moose.overlapping_tanks.has(game.player), "Area2D exit clears contact tracking")
	print("MECHANICS TEST FAILURES: ", failures)
	quit(1 if failures else 0)
