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

func button(text: String) -> Button:
	for node in game.panel.find_children("*", "Button", true, false):
		if node.text == text:
			return node
	return null

func content() -> String:
	var text := ""
	for node in game.panel.find_children("*", "Label", true, false):
		text += node.text + "\n"
	return text

func click(text: String) -> void:
	await process_frame
	await process_frame
	var target := button(text)
	check(target != null and not target.disabled, "Navigation button available: " + text)
	if target == null:
		return
	# Deliver real GUI mouse events through the viewport, not callback calls.
	for pressed in [true, false]:
		var event := InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_LEFT
		event.position = target.get_global_rect().get_center()
		event.pressed = pressed
		root.push_input(event)
	await process_frame

func press_escape() -> void:
	for pressed in [true, false]:
		var event := InputEventKey.new()
		event.keycode = KEY_ESCAPE
		event.pressed = pressed
		root.push_input(event)
	await process_frame

func run() -> void:
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	check("MOOOZE TANKS" in content() and button("Exit") != null, "UI1: title and Exit retained")
	await click("Controls")
	check("PLAYER 1" in content() and "PLAYER 2" in content() and "T up / F left / G down / H right" in content(), "UI5: distinct controls and correct P2 aim")
	await click("Help")
	check("20 damage" in content() and "100 health and 3 lives" in content() and "35 icy bricks" in content(), "UI5: help matches existing gameplay")
	await click("Main Menu")
	await click("Credits")
	check("Olaniyi Tolulope" in content() and "Anna-Marie Oyemiren" in content(), "Credits retain confirmed team roles")
	await click("Back to Menu")
	await click("Sound")
	check(game.panel.find_children("*", "HSlider", true, false).size() == 1, "Existing volume control retained")
	await click("Back to Menu")
	await click("Play")
	check(button("Host Game - Coming with multiplayer").disabled and button("Join Game - Coming with multiplayer").disabled, "UI1: unavailable network modes retained and disabled")
	await click("Local Co-op / 2 Players")
	check(game.local_coop and game.player_two != null, "UI1: Play selects local co-op")
	check(game.hud_root.get_global_rect().end.y < 91 and game.hud_root.get_node("MooseTankLogo").get_global_rect().end.y < 91 and game.hud_stats.get_global_rect().end.y < 91, "UI2: logo and HUD stay above arena")
	await press_escape()
	check(paused and button("Resume") != null, "UI3: Escape opens pause overlay")
	await press_escape()
	check(not paused and game.state == "playing", "UI3: Escape resumes gameplay")
	game.player.take_damage(25)
	game.player_two.take_damage(40)
	game.on_brick_destroyed(Vector2(500, 400))
	await process_frame
	check("P1: 75 HEALTH / 3 LIVES" in game.hud.text and "P2: 60 HEALTH / 3 LIVES" in game.hud.text and "TEAM SCORE: 0100" in game.hud_stats.text, "UI2: both vitals and shared score match game data")
	game.pause_button.pressed.emit()
	var time: float = game.elapsed
	var position: Vector2 = game.player.position
	Input.action_press("move_right")
	await create_timer(0.15).timeout
	Input.action_release("move_right")
	check(paused and game.elapsed == time and game.player.position == position, "UI3: pause freezes clock and movement")
	await click("Resume")
	check(not paused and game.state == "playing", "UI3: Resume button restores play")
	game.pause_game()
	await click("Restart")
	check(not paused and game.local_coop and game.score == 0 and game.player_two.health == 100, "UI3: restart resets match and keeps mode")
	game.pause_game()
	await click("Main Menu")
	check(game.state == "menu" and not paused, "UI3: paused Main Menu unpauses and exits field")
	await click("Play")
	await click("Solo Practice")
	check(not game.local_coop and game.player_two == null, "UI1: solo remains available")
	for child in game.world.get_children():
		if child.get_script() == load("res://scripts/brick.gd") and not child.reinforced:
			child.hit()
	await process_frame
	await process_frame
	check(game.state == "results" and "Winner: Player 1" in content() and "3500 points" in content() and "35 / 35 bricks cleared" in content(), "UI4: solo winner and statistics reflect field clear")
	await click("Play Again")
	check(game.state == "playing" and game.score == 0 and not paused, "UI4: Play Again starts fresh")
	for i in range(3):
		game.player.take_damage(100)
	check("Winner: None" in content() and "0 health / 0 lives" in content() and "0 / 35 bricks cleared" in content(), "UI4: defeat has no invented winner and accurate stats")
	await click("Main Menu")
	await click("Play")
	await click("Local Co-op / 2 Players")
	for child in game.world.get_children():
		if child.get_script() == load("res://scripts/brick.gd") and not child.reinforced:
			child.hit()
	await process_frame
	await process_frame
	check("Winner: Team P1 + P2" in content() and "Shared team score: 3500" in content(), "UI4: cooperative team winner and shared score")
	await click("Main Menu")
	await process_frame
	check(not is_instance_valid(game.hud_root), "UI2: leaving gameplay removes entire HUD")
	print("UI TEST FAILURES: ", failures)
	quit(1 if failures else 0)
