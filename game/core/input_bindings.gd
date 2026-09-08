extends Node
## Shared logical actions. Gameplay and touch adapters arrive in later phases.

func _ready() -> void:
	bind_key("move_forward", KEY_W)
	bind_key("move_backward", KEY_S)
	bind_key("move_left", KEY_A)
	bind_key("move_right", KEY_D)
	bind_key("jump", KEY_SPACE)
	bind_key("sprint", KEY_SHIFT)
	bind_key("interact", KEY_E)
	bind_key("pause", KEY_ESCAPE)
	bind_axis("move_left", JOY_AXIS_LEFT_X, -1.0)
	bind_axis("move_right", JOY_AXIS_LEFT_X, 1.0)
	bind_axis("move_forward", JOY_AXIS_LEFT_Y, -1.0)
	bind_axis("move_backward", JOY_AXIS_LEFT_Y, 1.0)
	bind_axis("look_left", JOY_AXIS_RIGHT_X, -1.0)
	bind_axis("look_right", JOY_AXIS_RIGHT_X, 1.0)
	bind_axis("look_up", JOY_AXIS_RIGHT_Y, -1.0)
	bind_axis("look_down", JOY_AXIS_RIGHT_Y, 1.0)
	bind_button("jump", JOY_BUTTON_A)
	bind_button("interact", JOY_BUTTON_X)
	bind_button("sprint", JOY_BUTTON_LEFT_STICK)
	bind_button("pause", JOY_BUTTON_START)

func ensure_action(action: StringName) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action, 0.2)

func bind_key(action: StringName, key: Key) -> void:
	ensure_action(action)
	var event := InputEventKey.new()
	event.physical_keycode = key
	InputMap.action_add_event(action, event)

func bind_axis(action: StringName, axis: JoyAxis, value: float) -> void:
	ensure_action(action)
	var event := InputEventJoypadMotion.new()
	event.axis = axis
	event.axis_value = value
	InputMap.action_add_event(action, event)

func bind_button(action: StringName, button: JoyButton) -> void:
	ensure_action(action)
	var event := InputEventJoypadButton.new()
	event.button_index = button
	InputMap.action_add_event(action, event)
