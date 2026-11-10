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
	check(game.sound.voices.size() == 10, "Ten original audio streams loaded")
	game.sound.play("click")
	check(game.sound.voices.click.playing, "Button click playback starts")
	game.start_game(true)
	game.player.shoot()
	game.player_two.shoot()
	check(game.sound.voices.shoot.playing and game.sound.voices.shoot.max_polyphony == 2, "Both player shots use bounded playback")
	await process_frame
	check(game.sound.voices.music.playing and game.sound.voices.idle.playing, "Music and idle begin without movement")
	game.burst(Vector2(300, 300))
	check(not game.sound.voices.explosion.playing, "Visual projectile bursts do not trigger tank explosions")
	for tank in [game.player, game.player_two]:
		game.sound.voices.moose_roar.stop()
		game.sound.last_played.moose_roar = Time.get_ticks_msec()
		tank.take_moose_hit(Vector2.RIGHT)
		check(game.sound.voices.moose_roar.playing and not game.sound.voices.moose_blast.playing, "Contact roar bypasses ambient cooldown for player %d" % tank.player_number)
		check(game.sound.voices.moose_roar.volume_db > game.sound.voices.engine.volume_db + 10, "Contact roar stands out above driving engine")
		var stamp = game.sound.last_played.moose_roar
		check(not tank.take_moose_hit() and stamp == game.sound.last_played.moose_roar, "Protected contact does not retrigger roar")
		game.sound.last_played.erase("explosion")
		tank.take_damage(100)
		check(game.sound.voices.explosion.playing, "Life loss explosion for player %d" % tank.player_number)
	game.sound.last_played.erase("moose_roar")
	await create_timer(1.5).timeout
	check(game.sound.last_played.has("moose_roar"), "Emerging moose trigger a bounded roar")
	var obstacle = game.world.get_children().filter(func(node): return node.get_script() == game.Brick and not node.reinforced)[0]
	obstacle.hit()
	check(game.sound.voices.brick.playing, "Brick destruction sound starts")
	Input.action_press("p2_move_left")
	await frames(15)
	await process_frame
	check(game.sound.voices.engine.playing, "P2 movement starts engine loop")
	Input.action_release("p2_move_left")
	await create_timer(0.2).timeout
	check(not game.sound.voices.engine.playing, "Engine stops on movement release")
	Input.action_press("move_right")
	await frames(15)
	await process_frame
	check(game.sound.voices.engine.playing, "P1 movement starts engine loop")
	game.pause_game()
	check(not game.sound.voices.engine.playing and not game.sound.voices.shoot.playing, "Pause stops gameplay sounds")
	check(game.sound.voices.music.stream_paused and not game.sound.voices.idle.playing, "Pause suspends music and idle")
	Input.action_release("move_right")
	game.resume_game()
	game.sound.set_volume(0)
	game.player.shoot()
	game.burst(Vector2.ZERO)
	game.sound.play("click")
	check(not game.sound.voices.shoot.playing and not game.sound.voices.explosion.playing and not game.sound.voices.click.playing, "Mute suppresses sound events")
	game.sound.set_volume(0.5)
	game.sound.play("shoot")
	check(game.sound.voices.shoot.playing and game.sound.voices.shoot.volume_db < -20, "Unmute restores attenuated playback")
	game.finish_game()
	check(game.sound.voices.victory.playing and not game.sound.voices.engine.playing, "Field clear plays victory and stops engines")
	game.restart_game()
	check(not game.sound.voices.victory.playing, "Restart clears victory")
	game.player.lives = 1
	game.player_two.lives = 1
	for tank in [game.player, game.player_two]:
		tank.health = tank.MOOSE_DAMAGE
		tank.moose_cooldown = 0
		tank.take_moose_hit(Vector2.RIGHT)
	await process_frame
	check(game.state == "dying" and game.sound.voices.explosion.playing and game.sound.voices.moose_roar.playing, "Final moose hit plays explosion and roar before Game Over")
	check(not game.player.visible and not game.player_two.visible and not is_instance_valid(game.panel), "Destroyed tanks disappear while explosion is unobscured")
	var final_time = game.elapsed
	await create_timer(1.2).timeout
	check(game.state == "results" and not game.sound.voices.explosion.playing and game.elapsed == final_time, "Game Over waits for explosion with match time frozen")
	check(game.world.get_children().filter(func(node): return node.get_script() == load("res://scripts/tank_explosion.gd")).is_empty(), "Explosion effects clean up after defeat")
	check(not game.sound.voices.victory.playing and not game.sound.voices.idle.playing, "Defeat never plays victory or leaves idle looping")
	game.restart_game()
	game.remaining = 1
	game.sound.last_played.erase("brick")
	game.on_brick_destroyed(Vector2(300, 300))
	await process_frame
	check(game.state == "results" and game.sound.voices.brick.playing, "Last obstacle destruction rings through field-clear results")
	game.start_game()
	game.sound.set_volume(0)
	game.player.lives = 1
	game.player.health = game.player.MOOSE_DAMAGE
	game.player.take_moose_hit()
	check(game.state == "dying" and not game.sound.voices.explosion.playing, "Muted defeat still begins visual explosion")
	await create_timer(1.2).timeout
	check(game.state == "results", "Muted explosion still reaches Game Over")
	game.restart_game()
	game.player.lives = 1
	game.player.take_damage(100)
	game.restart_game()
	await create_timer(1.2).timeout
	check(game.state == "playing" and game.player.visible, "Restart cancels pending Game Over and restores visible tank")
	game.show_menu()
	game.show_sound()
	var slider = game.panel.find_children("*", "HSlider", true, false)[0]
	slider.value = 0
	check(game.sound.volume == 0, "Sound menu slider mutes")
	slider.value = 65
	check(is_equal_approx(game.sound.volume, 0.65), "Sound menu slider adjusts volume")
	await create_timer(0.4).timeout
	print("SOUND TEST FAILURES: ", failures)
	quit(1 if failures else 0)
