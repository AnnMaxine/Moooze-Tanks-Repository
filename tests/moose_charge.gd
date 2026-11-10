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
	var moose = get_nodes_in_group("moose")[0]
	for animal in get_nodes_in_group("moose"):
		animal.set_physics_process(false)
	game.player.position = Vector2(300, 420)
	game.player_two.position = Vector2(620, 420)
	moose.position = Vector2(500, 420)
	await frames(2)
	game.sound.voices.moose_roar.stop()
	game.sound.last_played.moose_roar = Time.get_ticks_msec()
	game.spawn_bullet(game.player.position, game.player.position + Vector2(50, 0), Vector2.RIGHT)
	await frames(15)
	check(moose.charge_target == game.player_two and moose.charge_remaining > 0, "Actual P1 snowball provokes nearest tank P2, not shooter")
	check(game.world.get_children().filter(func(node): return node.get_script() == game.Bullet).is_empty(), "Snowball is removed on moose impact")
	check(game.sound.voices.moose_roar.playing and game.sound.contact_roar, "Snowball impact triggers loud roar despite ambient cooldown")
	check(game.score == 0 and game.remaining == 35, "Moose hit does not destroy bricks or award points")
	moose.set_physics_process(true)
	await frames(4)
	check(moose.position.x > 500 and is_equal_approx(moose.velocity.length(), moose.CHARGE_SPEED), "Provoked moose charges faster toward nearest tank")
	game.pause_game()
	var at: Vector2 = moose.position
	var remaining: float = moose.charge_remaining
	await frames(5)
	moose.hit()
	check(moose.position == at and moose.charge_remaining == remaining, "Pause freezes charge and rejects hits")
	game.resume_game()
	await frames(25)
	check(game.player_two.health == 80 and game.player.health == 100 and moose.charge_remaining == 0, "Charge hits P2 once with existing damage and ends")
	check(not game.player_two.take_moose_hit(), "Charge preserves tank damage protection")
	moose.position = Vector2(500, 420)
	game.player.position = Vector2(300, 420)
	game.player_two.position = Vector2(900, 420)
	moose.hit()
	check(moose.charge_target == game.player, "New hit selects P1 when P1 is closer")
	game.player.active = false
	await frames(2)
	check(moose.charge_target == game.player_two, "Eliminated target is replaced with remaining active tank")
	game.player_two.active = false
	await frames(2)
	check(moose.charge_remaining == 0 and moose.charge_target == null, "No active targets cancels charge safely")
	game.player.active = true
	game.player.position = Vector2(500, 420)
	moose.position = Vector2(800, 420)
	moose.hit()
	moose.charge_remaining = 0.01
	await frames(3)
	check(moose.charge_remaining == 0 and is_equal_approx(moose.velocity.length(), moose.SPEED), "Expired charge returns to roaming speed")
	moose.position = Vector2(280, 380)
	game.player.position = Vector2(280, 190)
	moose.hit()
	await frames(15)
	check(moose.position.y >= 333 and moose.charge_remaining == 0, "Interior obstacle blocks and ends charge")
	moose.position = Vector2(160, 420)
	game.player.position = Vector2(50, 420)
	moose.hit()
	await frames(15)
	check(moose.position.x >= 133 and moose.charge_remaining == 0, "Reinforced perimeter contains charging moose")
	moose.set_physics_process(false)
	moose.position = Vector2(280, 200)
	moose.charge_remaining = 0
	game.player.position = Vector2(280, 380)
	await frames(2)
	game.spawn_bullet(game.player.position, game.player.position + Vector2(0, -50), Vector2.UP)
	await frames(15)
	check(moose.charge_remaining == 0 and game.score == 100, "Brick in front intercepts snowball before moose")
	game.sound.set_volume(0)
	moose.hit()
	check(moose.charge_remaining > 0 and not game.sound.voices.moose_roar.playing, "Mute suppresses roar without disabling charge")
	game.restart_game()
	await frames(2)
	check(get_nodes_in_group("moose").all(func(animal): return animal.charge_remaining == 0 and animal.charge_target == null), "Restart clears all charge targets and timers")
	game.show_menu()
	await frames(2)
	check(get_nodes_in_group("moose").is_empty(), "Menu clears charging moose")
	print("MOOSE CHARGE TEST FAILURES: ", failures)
	quit(1 if failures else 0)
