extends SceneTree

const HudValues = preload("res://tests/hud_values.gd")
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
	for moose in get_nodes_in_group("moose"):
		moose.process_mode = Node.PROCESS_MODE_DISABLED
	game.player.position = Vector2(450, 430)
	game.player_two.position = Vector2(550, 430)
	await frames(3)

func fire(tank: Node2D, angle: float) -> void:
	tank.turret.rotation = angle
	tank.shoot()
	await frames(8)

func content() -> String:
	var text := ""
	for label in game.panel.find_children("*", "Label", true, false):
		text += label.text + "\n"
	return text

func run() -> void:
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	await fresh()
	await fire(game.player, 0)
	check(game.player_two.health == 80 and game.player.health == 100 and HudValues.health(game, 2) == 80, "P1 shot damages only P2 by 20 and drains gas HUD")
	check(game.world.get_children().filter(func(n): return n is Bullet).is_empty(), "Tank impact removes projectile")
	await fire(game.player_two, PI)
	check(game.player.health == 80 and game.player_two.health == 80, "P2 can shoot P1 without self-damage")
	game.player.apply_powerup("heavy")
	await fire(game.player, 0)
	check(game.player_two.health == 40 and game.player.heavy_time > 0, "Heavy shot deals 40 while timed power-up is active")
	game.player_two.apply_powerup("shield")
	await fire(game.player, 0)
	check(game.player_two.health == 40, "Shield blocks enemy projectile damage")
	check(game.player_two.shield_time < 5.0 and game.player_two.shield_time > 4.0, "Real heavy hit removes two extra shield seconds")
	game.player_two.shield_time = 1.0
	await fire(game.player, 0)
	check(game.player_two.shield_time == 0 and game.player_two.health == 40, "Heavy hit exhausts shield without spillover damage")
	game.pause_game()
	game.player_two.take_projectile_hit(40)
	var shots: int = game.shots
	game.player.shoot()
	check(game.player_two.health == 40 and game.shots == shots, "Pause blocks damage and firing")
	game.resume_game()
	await fire(game.player, 0)
	check(game.player_two.lives == 2 and game.player_two.health == 100 and HudValues.lives(game, 2) == 2 and HudValues.health(game, 2) == 100, "Zero health removes one heart, respawns and refills gas")
	check(game.player_two.position == game.player_two.spawn_position and game.player_two.respawn_protection > 1.5, "Respawn position and two-second shot protection")
	game.player_two.position = Vector2(550, 430)
	await frames(2)
	await fire(game.player, 0)
	check(game.player_two.health == 100, "Incoming real shot cannot damage protected respawn")
	game.pause_game()
	var protection: float = game.player_two.respawn_protection
	await frames(5)
	check(game.player_two.respawn_protection == protection, "Pause freezes respawn protection")
	game.resume_game()
	game.player_two.respawn_protection = 0.03
	await frames(6)
	game.player.heavy_time = 0
	await fire(game.player, 0)
	check(game.player_two.health == 80, "Damage resumes when respawn protection expires")
	# Close-range muzzle sweep and overlapping tanks still exclude the shooter.
	game.player_two.position = game.player.position + Vector2(35, 0)
	await frames(3)
	await fire(game.player, 0)
	check(game.player_two.health == 60 and game.player.health == 80, "Close-range muzzle cannot bypass an opposing tank")
	game.player_two.position = game.player.position
	await frames(3)
	await fire(game.player, 0)
	check(game.player_two.health == 40 and game.player.health == 80, "Overlapping tanks still exclude only the shooter")
	# A brick shields the tank behind it; projectile is consumed at the first hit.
	await fresh()
	game.player.position = Vector2(280, 185)
	game.player_two.position = Vector2(280, 360)
	await frames(3)
	await fire(game.player, PI / 2)
	check(game.player_two.health == 100 and game.remaining == 34, "Brick cover intercepts shots before the opponent")
	# Real hits through all three lives determine either winner.
	for losing_number in [1, 2]:
		await fresh()
		var loser = game.player if losing_number == 1 else game.player_two
		var winner = game.player_two if losing_number == 1 else game.player
		var angle := PI if losing_number == 1 else 0.0
		for life in range(3):
			loser.position = Vector2(450 if losing_number == 1 else 550, 430)
			loser.respawn_protection = 0
			await frames(3)
			for shot in range(5):
				await fire(winner, angle)
		check(loser.lives == 0 and loser.health == 0 and not loser.active and game.state == "dying" and paused, "All three lives lost to real shots ends duel for P%d" % losing_number)
		check(game.sound.voices.defeat.playing and not game.sound.voices.music.playing, "Loss cue plays while duel freezes")
		var time: float = game.elapsed
		var winner_health: int = winner.health
		winner.take_projectile_hit(100)
		await create_timer(2.4).timeout
		check(game.state == "results" and game.winner_number == winner.player_number and game.elapsed == time and winner.health == winner_health, "Winner is stable and gameplay cannot continue after elimination")
		check(content().contains("Winner: Player %d" % winner.player_number) and content().contains("GAME OVER - PLAYER %d" % losing_number), "Win page identifies the correct winner and loser")
		var confetti = game.panel.get_node_or_null("VictoryConfetti")
		check(confetti != null and confetti.pieces.size() == 100 and game.sound.voices.victory.playing, "Victory page plays win cue and bounded confetti")
		var confetti_age: float = confetti.age
		await frames(5)
		check(confetti.age > confetti_age and confetti.mouse_filter == Control.MOUSE_FILTER_IGNORE, "Confetti animates during results and cannot block buttons")
		game.restart_game()
		await frames(3)
		check(not is_instance_valid(confetti) and not game.sound.voices.victory.playing and not game.sound.voices.defeat.playing and game.player.lives == 3 and game.player_two.lives == 3, "Replay clears outcome effects/audio and resets both tanks")
	# Solo defeat has sad audio only; solo victory has confetti too.
	game.start_game()
	game.player.lives = 1
	game.player.take_damage(100)
	await create_timer(1.2).timeout
	check(content().contains("GAME OVER") and game.sound.voices.defeat.playing and not game.panel.has_node("VictoryConfetti") and not game.sound.voices.victory.playing, "Solo Game Over has sad sound and no victory confetti")
	game.start_game()
	game.finish_game()
	check(content().contains("YOU WIN!") and game.panel.has_node("VictoryConfetti"), "Solo win also celebrates with confetti")
	game.show_menu()
	await frames(3)
	check(not game.panel.has_node("VictoryConfetti") and not game.sound.voices.defeat.playing and not game.sound.voices.victory.playing, "Main Menu cleans up result effects and audio")
	game.sound.set_volume(0)
	await fresh()
	game.player.lives = 1
	game.player.take_damage(100)
	await create_timer(2.4).timeout
	check(game.state == "results" and not game.sound.voices.defeat.playing and not game.sound.voices.victory.playing, "Muted duel still reaches correct results without sound")
	print("DUEL TEST FAILURES: ", failures)
	quit(1 if failures else 0)
