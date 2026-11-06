extends Node

var volume := 0.65
var voices: Dictionary = {}
var last_played: Dictionary = {}
const LEVELS := {"shoot": -16.0, "brick": -18.0, "explosion": -21.0, "click": -18.0, "engine": -29.0, "idle": -36.0, "music": -27.0, "moose_blast": -20.0, "moose_roar": -25.0, "victory": -20.0}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for sound in LEVELS:
		var voice := AudioStreamPlayer.new()
		var stream = load("res://assets/audio/" + sound + ".wav").duplicate()
		if sound in ["engine", "idle", "music"]:
			stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
			stream.loop_begin = 0
			stream.loop_end = stream.data.size() / 2
		voice.stream = stream
		voice.max_polyphony = 2 if sound == "shoot" else 1
		add_child(voice)
		voices[sound] = voice
	set_volume(volume)

func set_volume(value: float) -> void:
	volume = clampf(value, 0.0, 1.0)
	for sound in voices:
		voices[sound].volume_db = LEVELS[sound] + linear_to_db(maxf(volume, 0.00001))
		if volume == 0:
			voices[sound].stop()

func play(sound: String) -> void:
	if volume == 0:
		return
	var now := Time.get_ticks_msec()
	# Two simultaneous player shots are allowed; impacts are coalesced.
	var interval := 0 if sound == "shoot" else (4000 if sound == "moose_roar" else 90)
	if now - int(last_played.get(sound, -interval)) < interval:
		return
	last_played[sound] = now
	voices[sound].play()

# Contact takes priority over the ambient roar cooldown, without layering roars.
func play_moose_contact() -> void:
	if voices.moose_roar.playing:
		return
	last_played.erase("moose_roar")
	play("moose_roar")

# Shared engine beds avoid doubling the volume in co-op.
func set_loop(sound: String, enabled: bool) -> void:
	var voice: AudioStreamPlayer = voices[sound]
	if enabled and volume > 0:
		if not voice.playing:
			voice.play()
	else:
		voice.stop()

func update_ambience(playing: bool, moving: bool, idle: bool, paused: bool) -> void:
	set_loop("engine", playing and moving)
	set_loop("idle", playing and idle)
	voices.music.stream_paused = paused
	if not paused:
		set_loop("music", true)

func stop_gameplay() -> void:
	for sound in voices:
		if sound not in ["music", "click"]:
			voices[sound].stop()
