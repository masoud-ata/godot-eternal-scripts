@tool
extends EditorPlugin


var original_parent: Control
var scripts_panel: Control
var script_editor: ScriptEditor = null

var new_parent: Control
var new_scripts_dock := MarginContainer.new()


var docked := false


func _enter_tree():
	print("Eternal-scripts is on baby!")
	script_editor = get_editor_interface().get_script_editor()
	script_editor.editor_script_changed.connect(_on_editor_script_changed)
	script_editor.visibility_changed.connect(_on_editor_script_changed)

	original_parent = script_editor.get_child(0).get_child(1)
	scripts_panel = original_parent.get_child(0)

	_add_scripts_panel_to_new_scripts_dock()
	docked = true


func _exit_tree():
	print("Eternal-scripts is off.")

	script_editor.editor_script_changed.disconnect(_on_editor_script_changed)
	script_editor.visibility_changed.disconnect(_on_editor_script_changed)

	_revert_to_original()
	new_scripts_dock.queue_free()
	docked = false


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		var key_event = event as InputEventKey
		if key_event.shift_pressed and key_event.ctrl_pressed and key_event.keycode == KEY_F11:
			if docked:
				_revert_to_original()
			else:
				_add_scripts_panel_to_new_scripts_dock()
			docked = not docked


func _add_scripts_panel_to_new_scripts_dock() -> void:
	scripts_panel.reparent(new_scripts_dock)

	new_scripts_dock.name = "Scripts"
	new_scripts_dock.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	new_scripts_dock.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_control_to_dock(EditorPlugin.DOCK_SLOT_LEFT_UR, new_scripts_dock)

	new_parent = new_scripts_dock.get_parent()


func _revert_to_original() -> void:
	scripts_panel.reparent(original_parent)
	original_parent.move_child(scripts_panel, 0)
	remove_control_from_docks(new_scripts_dock)


func _on_editor_script_changed(_a = null):
	get_editor_interface().set_main_screen_editor("Script")
	if !script_editor.is_visible_in_tree():
		return
	new_parent.current_tab = new_scripts_dock.get_index()
