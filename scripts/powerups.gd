extends RefCounted

const TYPES := ["heavy", "shield", "speed", "health"]
const DURATION := 30.0
const SPEED_MULTIPLIER := 1.5
const HEAL_AMOUNT := 35
const BLAST_RADIUS := 58.0
const ICONS := {
	"heavy": preload("res://assets/powerup_heavy.svg"),
	"shield": preload("res://assets/powerup_shield_green.svg"),
	"speed": preload("res://assets/powerup_speed.svg"),
	"health": preload("res://assets/powerup_health.svg"),
}
const COLORS := {
	"heavy": Color("#ffae45"), "shield": Color("#62ff70"),
	"speed": Color("#9aff7a"), "health": Color("#ff709d"),
}
