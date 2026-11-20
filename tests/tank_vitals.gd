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
	for tank in [game.player, game.player_two]:
		tank.set_physics_process(false)
		check(tank.health_bar.value == 100 and tank.lives_label.text == "3", "Full overhead health and three lives")
		check(tank.user_id_label.get_parent() == tank.health_bar.get_parent() and not tank.health_bar.show_percentage
			and tank.user_id_label.position.y < tank.health_bar.position.y
			and tank.lives_label.global_position.x < tank.health_bar.global_position.x,
			"Sketch layout: player name above health, count inside left heart, no percentage")
		check(tank.user_id_label.text == "Player %d" % tank.player_number, "Local placeholder before server ID arrives")
		tank.user_id = "server-user-%d" % tank.player_number
		check(tank.user_id_label.text == tank.user_id, "User ID assignment immediately updates label")
		var offset: Vector2 = tank.vitals_display.global_position - tank.global_position
		tank.position += Vector2(30, -20)
		tank.chassis.rotation = 1.2
		tank.turret.rotation = 0.7
		check(tank.vitals_display.global_position - tank.global_position == offset and tank.vitals_display.get_global_transform().get_rotation() == 0,
			"Vitals follow tank without rotating with chassis or turret")
		tank.take_damage(27)
		check(tank.health_bar.value == 73 and tank.lives_label.text == "3", "Damage updates exact health without losing life")
		tank.apply_powerup("health")
		check(tank.health_bar.value == 100, "Recovery caps displayed health at 100")
		tank.take_damage(100)
		check(tank.health_bar.value == 100 and tank.lives_label.text == "2" and tank.user_id_label.text == tank.user_id,
			"Respawn refills bar, decrements lives and preserves ID")
	game.pause_game()
	game.player.take_damage(20)
	check(game.player.health_bar.value == 100, "Pause preserves displayed health")
	game.resume_game()
	game.player_two.take_damage(100)
	game.player_two.take_damage(100)
	check(game.player_two.health_bar.value == 0 and game.player_two.lives_label.text == "0", "Elimination stores zero health and lives")
	game.start_game()
	check(game.player.health_bar.value == 100 and game.player.lives_label.text == "3", "Solo has the same overhead vitals")
	game.start_game(true)
	for animal in get_nodes_in_group("moose"):
		animal.set_physics_process(false)
	for tank in [game.player, game.player_two]:
		var action := "move_right" if tank.player_number == 1 else "p2_move_right"
		tank.position = Vector2(616, 420)
		Input.action_press(action)
		for frame in range(16):
			await physics_frame
		check(tank.vitals_display.modulate.a <= 0.45, "Moving near a brick fades this tank vitals")
		Input.action_release(action)
		for frame in range(16):
			await physics_frame
		check(tank.vitals_display.modulate.a == 1.0, "Stopping restores full vitals opacity")
		tank.position = Vector2(640, 620)
		var moose = get_nodes_in_group("moose")[0]
		moose.position = Vector2(640, 570)
		Input.action_press(action)
		for frame in range(16):
			await physics_frame
		check(tank.vitals_display.modulate.a <= 0.45, "Moving near a moose fades this tank vitals")
		moose.position = Vector2(166, 206)
		for frame in range(16):
			await physics_frame
		check(tank.vitals_display.modulate.a == 1.0, "Moving into clear space restores opacity")
		Input.action_release(action)
	game.show_menu()
	await process_frame
	print("TANK VITALS FAILURES: ", failures)
	quit(1 if failures else 0)
