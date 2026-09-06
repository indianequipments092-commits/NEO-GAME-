extends Node

## Simple local settings controller for Phase 8.
const SETTINGS_PATH := "user://settings.cfg"

var music_enabled := true
var sfx_enabled := true
var screen_shake_enabled := true

func _ready() -> void:
	load_settings()

func toggle_music() -> void:
	music_enabled = not music_enabled
	save_settings()

func toggle_sfx() -> void:
	sfx_enabled = not sfx_enabled
	save_settings()

func toggle_screen_shake() -> void:
	screen_shake_enabled = not screen_shake_enabled
	save_settings()

func save_settings() -> void:
	var config := ConfigFile.new()
	config.set_value("audio", "music_enabled", music_enabled)
	config.set_value("audio", "sfx_enabled", sfx_enabled)
	config.set_value("gameplay", "screen_shake_enabled", screen_shake_enabled)
	config.save(SETTINGS_PATH)

func load_settings() -> void:
	var config := ConfigFile.new()
	if config.load(SETTINGS_PATH) != OK:
		return
	music_enabled = bool(config.get_value("audio", "music_enabled", true))
	sfx_enabled = bool(config.get_value("audio", "sfx_enabled", true))
	screen_shake_enabled = bool(config.get_value("gameplay", "screen_shake_enabled", true))
