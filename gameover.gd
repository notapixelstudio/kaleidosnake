extends CanvasItem

onready var cursor = $Cursor

func _ready() -> void:
	hide()
	yield(get_tree().create_timer(1), "timeout")
	#start(0)

func start() -> void:
	$anim.play("show")
	
	yield($anim, "animation_finished")
	$Options/Play.grab_focus()
	


func _on_btn_play_pressed():
	get_tree().reload_current_scene()


func _on_Options_focus(focus_node):
	if not cursor.visible:
		cursor.visible = true
	cursor.position.x = $Options.rect_position.x + focus_node.rect_position.x - 30



func _on_Quit_pressed():
	get_tree().quit()
