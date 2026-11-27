extends RefCounted

const TYPES := ["heavy", "shield", "speed"]
const DURATION := 10.0
const SHIELD_DURATION := 7.0
const HEAVY_SHIELD_PENALTY := 2.0
const SPEED_MULTIPLIER := 1.5
const BLAST_RADIUS := 58.0
const ICONS := {
	"heavy": preload("res://assets/powerup_heavy.svg"),
	"shield": preload("res://assets/powerup_shield_green.svg"),
	"speed": preload("res://assets/powerup_speed.svg"),
}
const COLORS := {
	"heavy": Color("#ffae45"), "shield": Color("#62ff70"),
	"speed": Color("#9aff7a"),
}
