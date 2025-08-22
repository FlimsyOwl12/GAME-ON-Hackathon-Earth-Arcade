extends Control

@onready var music_player = $AudioPlayer
@onready var play_click = $PLAY/PlayClickSound
@onready var option_click = $OPTION/OptionClickSound
@onready var exit_click = $EXIT/ExitClickSound

func _ready():
	fade_in_music()

func fade_in_music():
	var tween := get_tree().create_tween()
	music_player.volume_db = -80
	music_player.play()
	tween.tween_property(music_player, "volume_db", 10, 1)

func fade_out_music():
	var tween := get_tree().create_tween()
	tween.tween_property(music_player, "volume_db", -80, 1)

func _on_play_pressed():
	play_click.play()

func _on_option_pressed():
	option_click.play()

func _on_exit_pressed():
	exit_click.play()
