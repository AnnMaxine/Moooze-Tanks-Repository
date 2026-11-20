extends SceneTree

const Brick = preload("res://scripts/brick.gd")
var failures := 0

func _initialize() -> void:
	run.call_deferred()

func check(condition: bool, description: String) -> void:
	if condition:
		print("PASS: ", description)
	else:
		push_error("FAIL: " + description)
		failures += 1

func bricks(game: Node) -> Array:
	return game.world.get_children().filter(func(node): return node is Brick and not node.reinforced and not node.broken)

func check_projectile_replacement(game: Node, coop: bool, second_player: bool) -> void:
	game.start_game(coop)
	for child in game.world.get_children():
		if child.get_script() == load("res://scripts/moose.gd"):
			child.set_physics_process(false)
	var tank = game.player_two if second_player else game.player
	tank.set_physics_process(false)
	var original: Array = bricks(game)
	var target = original[0]
	var old_position: Vector2 = target.position
	tank.position = old_position + Vector2(0, -65)
	tank.turret.rotation = PI / 2
	for frame in range(3):
		await physics_frame
	tank.shoot()
	for frame in range(12):
		await physics_frame
	var after: Array = bricks(game)
	var replacements: Array = after.filter(func(node): return not original.has(node))
	var mode := "Solo" if not coop else ("Co-op P2" if second_player else "Co-op P1")
	check(game.shots == 1 and game.score == 100 and after.size() == 35 and replacements.size() == 1,
		mode + ": actual tank projectile destroys and replaces exactly one brick")
	if replacements.size() == 1:
		check(replacements[0].position.distance_to(old_position) >= 96 and replacements[0].visible,
			mode + ": replacement is visible at a different location")

func run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	await check_projectile_replacement(game, false, false)
	await check_projectile_replacement(game, true, false)
	await check_projectile_replacement(game, true, true)
	game.start_game(true)
	await physics_frame
	var original: Array = bricks(game)
	var target = original[0]
	var previous_position: Vector2 = target.position
	target.hit(game.player)
	target.hit(game.player)
	await process_frame
	await physics_frame
	var after: Array = bricks(game)
	var replacements: Array = after.filter(func(node): return not original.has(node))
	check(after.size() == 35 and replacements.size() == 1, "R8: one replacement per destroyed brick, including repeated hits")
	check(game.score == 100 and game.remaining == 34, "UI2/UI4: original score and 35-destruction progress preserved")
	if replacements.size() == 1:
		var replacement = replacements[0]
		check(replacement.position.distance_to(previous_position) >= 96, "R4/R8: replacement appears elsewhere")
		var clear := true
		for other in after:
			if other != replacement:
				clear = clear and (absf(other.position.x - replacement.position.x) >= 52 or absf(other.position.y - replacement.position.y) >= 44)
		check(clear and replacement.position.distance_to(game.player.position) >= 90 and replacement.position.distance_to(game.player_two.position) >= 90, "R5/R9: replacement does not overlap bricks or tanks")
		check(replacement.get_child_count() == 2, "R4: replacement rewards remain hidden")
		# Force a known reward to verify replacement signal ownership and reveal location.
		replacement.powerup = "shield"
		replacement.hit(game.player_two)
		check(game.player_two.shield_time > 0 and game.player.shield_time == 0, "R7/R8: replacement reward goes to shooter")
	game.start_game()
	await process_frame
	bricks(game)[0].hit(game.player)
	await process_frame
	await physics_frame
	check(bricks(game).size() == 35 and game.remaining == 34 and game.score == 100, "R8: Solo destruction replaces a brick without extending the goal")
	for brick in bricks(game):
		brick.hit()
	await process_frame
	await process_frame
	check(game.state == "results" and game.remaining == 0 and game.score == 3500, "UI4: Solo still ends after 35 destructions")
	game.start_game(true)
	await process_frame
	bricks(game)[0].hit()
	game.start_game(true)
	await process_frame
	await process_frame
	check(bricks(game).size() == 35 and game.score == 0, "R9: pending replacement cannot leak into restarted match")
	bricks(game)[0].hit()
	game.start_game()
	await process_frame
	await process_frame
	check(bricks(game).size() == 35 and game.score == 0, "R9: pending Duel replacement cannot leak into Solo")
	game.show_menu()
	await process_frame
	print("BRICK RESPAWN FAILURES: ", failures)
	quit(1 if failures else 0)
