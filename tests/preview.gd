extends SceneTree

func _initialize() -> void:
	run.call_deferred()

func run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
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
	await capture("results")
	game.show_menu()
	game.show_controls()
	await capture("controls")
	game.show_help()
	await capture("help")
	game.show_play()
	await capture("play")
	quit()

func capture(screen: String) -> void:
	await create_timer(0.2).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://tests/" + screen + "-preview.png")
