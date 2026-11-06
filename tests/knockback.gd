extends SceneTree

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
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game.start_game(true)
	await frames(2)
	for animal in get_nodes_in_group("moose"):
		animal.set_physics_process(false)
	for tank in [game.player, game.player_two]:
		tank.position = Vector2(500, 420)
		tank.take_moose_hit(Vector2.LEFT)
		var push: Vector2 = tank.hit_push
		check(not tank.take_moose_hit(Vector2.RIGHT) and tank.hit_push == push, "Cooldown blocks repeated knockback")
		game.pause_game()
		await frames(5)
		check(tank.position == Vector2(500, 420) and tank.hit_flash == tank.HIT_FLASH_TIME, "Pause freezes recoil and flash")
		game.resume_game()
		await frames(24)
		check(tank.position.x < 450 and tank.position.x > 400 and tank.hit_push == Vector2.ZERO and tank.modulate == Color.WHITE, "Either tank recoils visibly then stops and regains normal color")
		tank.position = Vector2(140, 420)
		tank.moose_cooldown = 0
		tank.take_moose_hit(Vector2.LEFT)
		await frames(24)
		check(tank.position.x >= 135, "Recoil cannot cross forest perimeter")
		tank.position = Vector2(280, 350)
		tank.moose_cooldown = 0
		tank.take_moose_hit(Vector2.UP)
		await frames(24)
		check(tank.position.y >= 335, "Recoil cannot cross icy bricks")
		tank.health = 20
		tank.moose_cooldown = 0
		tank.take_moose_hit(Vector2.LEFT)
		check(tank.position == tank.spawn_position and tank.hit_push == Vector2.ZERO and tank.hit_flash == 0, "Lethal impact does not push respawned tank")
	game.player.position = Vector2(500, 420)
	game.player.moose_cooldown = 0
	game.player.take_moose_hit(Vector2.LEFT)
	Input.action_press("move_right")
	Input.action_press("fire")
	await frames(4)
	Input.action_release("move_right")
	Input.action_release("fire")
	check(game.player.position.x < 500 and game.shots > 0 and game.player.turret.global_position == game.player.global_position, "Impact remains visible against movement input; aiming/attachment and firing remain active")
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://tests/hit-preview.png")
	game.restart_game()
	await frames(2)
	check(game.player.hit_push == Vector2.ZERO and game.player.hit_flash == 0, "Restart clears impact feedback")
	print("KNOCKBACK TEST FAILURES: ", failures)
	quit(1 if failures else 0)
