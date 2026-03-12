@tool
extends EditorPlugin


var script_editor: ScriptEditor = null
var scripts_list_original_parent: Control
var scripts_list_panel: Control

var new_scripts_dock: EditorDock


func _enter_tree():
	script_editor = EditorInterface.get_script_editor()

	scripts_list_original_parent = script_editor.get_child(0).get_child(1)
	scripts_list_panel = scripts_list_original_parent.get_child(0)

	_add_scripts_list_panel_to_new_scripts_dock()


func _exit_tree():
	_revert_to_original_layout()
	remove_dock(new_scripts_dock)
	new_scripts_dock.queue_free()


func _input(event: InputEvent) -> void:
	var left_mouse_clicked = event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed()

	if left_mouse_clicked:
		var mouse_pos = script_editor.get_viewport().get_mouse_position()
		if scripts_list_panel.get_global_rect().has_point(mouse_pos):
			_on_editor_script_changed()


func _add_scripts_list_panel_to_new_scripts_dock() -> void:
	new_scripts_dock = EditorDock.new()
	new_scripts_dock.title = "Scripts"
	new_scripts_dock.default_slot = EditorDock.DOCK_SLOT_LEFT_UL
	scripts_list_panel.reparent(new_scripts_dock)
	add_dock(new_scripts_dock)


func _revert_to_original_layout() -> void:
	scripts_list_panel.reparent(scripts_list_original_parent)
	scripts_list_original_parent.move_child(scripts_list_panel, 0)


func _on_editor_script_changed(_a = null):
	EditorInterface.set_main_screen_editor("Script")
