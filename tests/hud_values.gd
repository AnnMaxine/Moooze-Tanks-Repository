extends RefCounted

# Read rendered control values, so tests catch stale HUD data after gameplay events.
static func health(game: Node, number: int = 1) -> int:
	var tank = game.player if number == 1 else game.player_two
	return int(tank.health_bar.value)

static func lives(game: Node, number: int = 1) -> int:
	var tank = game.player if number == 1 else game.player_two
	return int(tank.lives_label.text)
