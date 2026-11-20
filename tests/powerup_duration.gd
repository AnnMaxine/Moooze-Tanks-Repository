extends SceneTree

var failures := 0

func _initialize() -> void:
	run.call_deferred()

func check(condition: bool, description: String) -> void:
	if condition:
		print("PASS: ", description)
	else:
		push_error("FAIL: " + description)
		failures += 1

func run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game.start_game(true)
	for moose in get_nodes_in_group("moose"):
		moose.set_physics_process(false)
	for tank in [game.player, game.player_two]:
		tank.take_damage(50)
		for kind in ["heavy", "shield", "speed", "health"]:
			tank.apply_powerup(kind)
		check(tank.shield_time == 30.0 and tank.speed_time == 30.0 and tank.recovery_time == 30.0 and tank.heavy_time == 30.0,
			"All duration effects begin at thirty seconds")
		check(tank.health == 85, "Recovery still heals immediately")
	await create_timer(5.1).timeout
	for tank in [game.player, game.player_two]:
		check(tank.shield_time > 0 and tank.speed_time > 0 and tank.recovery_time > 0 and tank.heavy_time > 0,
			"Power-ups remain visible and active beyond five seconds")
	game.pause_game()
	var before: float = game.player.recovery_time
	await create_timer(0.2).timeout
	check(game.player.recovery_time == before, "Pause freezes duration")
	game.resume_game()
	await create_timer(25.2).timeout
	for tank in [game.player, game.player_two]:
		check(tank.powerup_status() == "No power-up", "Timed effects expire after thirty gameplay seconds")
		check(tank.health == 85, "Expired recovery feedback does not remove restored health")
		tank.shoot()
		check(not tank.shot_is_heavy, "Heavy shots stop when thirty-second timer expires")
		tank.apply_powerup("heavy")
		var duration: float = tank.heavy_time
		for shot in range(6):
			tank.shoot()
		check(tank.shot_is_heavy and tank.heavy_time == duration, "More than five shots stay heavy without consuming duration")
		tank.apply_powerup("health")
		check(tank.recovery_time == 30.0 and tank.health == 100, "Repeat recovery refreshes timer and respects health cap")
	game.show_menu()
	await process_frame
	print("POWERUP DURATION FAILURES: ", failures)
	quit(1 if failures else 0)
