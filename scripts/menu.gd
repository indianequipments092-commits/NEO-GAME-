extends CanvasLayer

## Phase 8 menu and settings controller.
@onready var pause_panel: Control = $PausePanel
@onready var settings_panel: Control = $SettingsPanel
@onready var music_button: Button = $SettingsPanel/Panel/VBox/MusicButton
@onready var sfx_button: Button = $SettingsPanel/Panel/VBox/SFXButton
@onready var shake_button: Button = $SettingsPanel/Panel/VBox/ShakeButton

var settings: Node

func _ready() -> void:
	settings = get_node_or_null("../Settings")
	pause_panel.visible = false
	settings_panel.visible = false
	_refresh_settings_labels()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if settings_panel.visible:
			_close_settings()
		else:
			_toggle_pause()

func _toggle_pause() -> void:
	pause_panel.visible = not pause_panel.visible
	get_tree().paused = pause_panel.visible
	if pause_panel.visible:
		$PausePanel/VBox/ResumeButton.grab_focus.call_deferred()

func _on_resume_pressed() -> void:
	pause_panel.visible = false
	get_tree().paused = false

func _on_settings_pressed() -> void:
	pause_panel.visible = false
	settings_panel.visible = true
	$SettingsPanel/Panel/VBox/MusicButton.grab_focus.call_deferred()

func _close_settings() -> void:
	settings_panel.visible = false
	pause_panel.visible = true
	$PausePanel/VBox/ResumeButton.grab_focus.call_deferred()

func _on_music_pressed() -> void:
	if settings:
		settings.toggle_music()
	_refresh_settings_labels()

func _on_sfx_pressed() -> void:
	if settings:
		settings.toggle_sfx()
	_refresh_settings_labels()

func _on_shake_pressed() -> void:
	if settings:
		settings.toggle_screen_shake()
	_refresh_settings_labels()

func _on_back_pressed() -> void:
	_close_settings()

func _refresh_settings_labels() -> void:
	if not settings:
		return
	music_button.text = "MUSIC: ON" if settings.music_enabled else "MUSIC: OFF"
	sfx_button.text = "SFX: ON" if settings.sfx_enabled else "SFX: OFF"
	shake_button.text = "SCREEN SHAKE: ON" if settings.screen_shake_enabled else "SCREEN SHAKE: OFF"
