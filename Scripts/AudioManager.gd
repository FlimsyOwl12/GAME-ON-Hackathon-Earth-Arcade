extends Node

var sfx_volume_db: float = 0.0
var music_volume_db: float = 0.0
var music_player: AudioStreamPlayer
var music_stream: AudioStream = null  # Currently playing music stream

func _ready():
	music_player = AudioStreamPlayer.new()
	music_player.bus = "Music"
	music_player.volume_db = -80.0  # Start muted
	add_child(music_player)

# Volume setters
func set_sfx_volume(value: float, max_value: float):
	var ratio = clamp(value / max_value, 0.0, 1.0)
	var db = linear_to_db(ratio)
	if is_inf(db) or is_nan(db):
		db = -80.0
	sfx_volume_db = db

func set_music_volume(value: float, max_value: float):
	var ratio = clamp(value / max_value, 0.0, 1.0)
	var db = linear_to_db(ratio)
	if is_inf(db) or is_nan(db):
		db = -80.0
	music_volume_db = db
	music_player.volume_db = db

# Volume appliers
func apply_sfx_volume(player: AudioStreamPlayer):
	if player:
		player.volume_db = sfx_volume_db

func apply_music_volume(player: AudioStreamPlayer):
	if player:
		player.volume_db = music_volume_db

# Safe fade-in to current music_volume_db
func fade_in_music(duration: float = 2.0) -> void:
	var start_db = music_player.volume_db
	var target_db = music_volume_db
	if is_nan(start_db) or is_inf(start_db):
		start_db = -80.0
	if is_nan(target_db) or is_inf(target_db):
		target_db = -80.0

	var time_passed := 0.0
	while time_passed < duration:
		await get_tree().process_frame
		time_passed += get_process_delta_time()
		var t = clamp(time_passed / duration, 0.0, 1.0)
		music_player.volume_db = lerp(start_db, target_db, t)
	music_player.volume_db = target_db

# Safe fade-out
func fade_out_music(target_db: float = -80.0, duration: float = 2.0) -> void:
	var start_db = music_player.volume_db
	if is_nan(start_db) or is_inf(start_db):
		start_db = -80.0
	if is_nan(target_db) or is_inf(target_db):
		target_db = -80.0

	var time_passed := 0.0
	while time_passed < duration:
		await get_tree().process_frame
		time_passed += get_process_delta_time()
		var t = clamp(time_passed / duration, 0.0, 1.0)
		music_player.volume_db = lerp(start_db, target_db, t)
	music_player.volume_db = target_db

	# Stop playback and clear stream
	music_player.stop()
	music_stream = null

# Play music with fade-in to current music_volume_db
func play_music_stream(stream: AudioStream, fade_in_duration: float = 2.0) -> void:
	if not stream:
		return

	# Avoid restarting same stream
	if music_stream == stream and music_player.playing:
		print("Requested music is already playing.")
		return

	music_stream = stream
	music_player.stream = stream
	music_player.play()
	await fade_in_music(fade_in_duration)
