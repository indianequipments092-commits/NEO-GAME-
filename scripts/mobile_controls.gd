extends CanvasLayer

## Touch controls for Android/mobile builds. Hidden on devices without touch input.
@onready var controls: Control = $Controls
@onready var buttons := {
	"move_left": $Controls/Left,
	"move_right": $Controls/Right,
	"move_up": $Controls/Up,
	"move_down": $Controls/Down,
	"fire": $Controls/Fire
}

func _ready() -> void:
	controls.visible = DisplayServer.is_touchscreen_available()
	for action in buttons:
		var button: Button = buttons[action]
		button.button_down.connect(_press_action.bind(action))
		button.button_up.connect(_release_action.bind(action))

func _press_action(action: String) -> void:
	Input.action_press(action)

func _release_action(action: String) -> void:
	Input.action_release(action)
