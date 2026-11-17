extends RefCounted

# Read rendered control values, so tests catch stale HUD data after gameplay events.
static func health(game: Node, number: int = 1) -> int:
	var total := 0
	for can in game.vitals_rows[number - 1].fuel:
		total += int(can.value)
	return total

static func lives(game: Node, number: int = 1) -> int:
	var total := 0
	for heart in game.vitals_rows[number - 1].hearts:
		if heart.modulate.a == 1.0:
			total += 1
	return total
