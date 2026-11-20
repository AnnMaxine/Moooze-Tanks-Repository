extends SceneTree

func _initialize() -> void:
	run.call_deferred()

func run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	if "--powerup-timers" in OS.get_cmdline_user_args():
		game.start_game(true)
		for animal in get_nodes_in_group("moose"):
			animal.set_physics_process(false)
		game.player.position = Vector2(450, 420)
		game.player_two.position = Vector2(830, 420)
		for tank in [game.player, game.player_two]:
			for kind in game.Powerups.TYPES:
				tank.apply_powerup(kind)
		game.player_two.heavy_time = 15
		game.player_two.shield_time = 15
		game.player_two.speed_time = 15
		game.player_two.recovery_time = 15
		await capture("powerup-timers")
		quit()
		return
	if "--angry-moose" in OS.get_cmdline_user_args():
		game.start_game(true)
		for animal in get_nodes_in_group("moose"):
			animal.set_physics_process(false)
		var moose = get_nodes_in_group("moose")[0]
		moose.position = Vector2(640, 420)
		game.player.position = Vector2(460, 420)
		game.player_two.position = Vector2(850, 420)
		game.player.user_id = "Player 1"
		game.player_two.user_id = "Player 2"
		moose.hit()
		moose.set_physics_process(true)
		await capture("angry-moose")
		game.start_game()
		game.player.position = Vector2(280, 380)
		game.player.apply_powerup("shield")
		Input.action_press("move_right")
		await create_timer(0.25).timeout
		paused = true
		Input.action_release("move_right")
		await capture("translucent-vitals")
		quit()
		return
	if "--tank-vitals" in OS.get_cmdline_user_args():
		game.start_game(true)
		game.player.user_id = "Player-ID-101"
		game.player_two.user_id = "Player-ID-202"
		game.player.position = Vector2(440, 420)
		game.player_two.position = Vector2(820, 420)
		game.player.take_damage(100)
		game.player.position = Vector2(440, 420)
		game.player.take_damage(35)
		game.player_two.take_damage(60)
		await capture("tank-vitals")
		quit()
		return
	if "--lobby" in OS.get_cmdline_user_args():
		await capture("menu")
		game.show_lobby()
		await capture("lobby")
		quit()
		return
	if "--snowballs" in OS.get_cmdline_user_args():
		game.start_game(true)
		await create_timer(0.1).timeout
		game.player.turret.rotation = 0.0
		game.player_two.turret.rotation = PI
		game.player_two.apply_powerup("heavy")
		game.player.shoot()
		game.player_two.shoot()
		await create_timer(0.08).timeout
		paused = true
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://tests/snowballs-preview.png")
		quit()
		return
	if "--outcomes" in OS.get_cmdline_user_args():
		game.start_game()
		game.player.lives = 1
		game.player.take_damage(100)
		await create_timer(1.2).timeout
		await capture("game-over")
		for winner in [1, 2]:
			game.start_game(true)
			var loser = game.player_two if winner == 1 else game.player
			loser.lives = 1
			loser.take_damage(100)
			await create_timer(2.4).timeout
			await capture("player-%d-wins" % winner)
		game.start_game()
		game.finish_game()
		await capture("solo-win")
		quit()
		return
	if "--vitals" in OS.get_cmdline_user_args():
		game.start_game(true)
		game.player.take_damage(100)
		game.player.take_damage(55)
		game.player_two.take_damage(25)
		await capture("hidden-powerups")
		game.player.position = Vector2(424, 187)
		game.player.turret.rotation = PI / 2
		game.player.shoot()
		await capture("revealed-powerup")
		game.show_menu()
		quit()
		return
	if "--powerups" in OS.get_cmdline_user_args():
		game.start_game(true)
		game.player.position = Vector2(470, 420)
		game.player_two.position = Vector2(810, 420)
		game.player.apply_powerup("heavy")
		game.player.apply_powerup("shield")
		game.player_two.apply_powerup("speed")
		game.player_two.take_damage(35)
		game.player_two.apply_powerup("health")
		await capture("powerups")
		game.show_menu()
		quit()
		return
	if "--explosion" in OS.get_cmdline_user_args():
		game.start_game()
		game.player.lives = 1
		game.player.health = game.player.MOOSE_DAMAGE
		game.player.take_moose_hit(Vector2.RIGHT)
		await capture("explosion")
		quit()
		return
	await create_timer(0.5).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://tests/menu-preview.png")
	game.start_game()
	await create_timer(0.5).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://tests/game-preview.png")
	game.start_game(true)
	await create_timer(2.5).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://tests/coop-preview.png")
	game.pause_game()
	await capture("pause")
	game.resume_game()
	for child in game.world.get_children():
		if child.get_script() == load("res://scripts/brick.gd") and not child.reinforced:
			child.hit()
	game.player_two.lives = 1
	game.player_two.take_damage(100)
	await create_timer(2.4).timeout
	await capture("results")
	game.show_menu()
	game.show_controls()
	await capture("controls")
	game.show_lobby()
	await capture("play")
	await capture("lobby")
	game.show_sound()
	await capture("sound")
	game.show_credits()
	await capture("credits")
	quit()

func capture(screen: String) -> void:
	await create_timer(0.2).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://tests/" + screen + "-preview.png")
