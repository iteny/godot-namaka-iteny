extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ServerConnection.save_email("iteny@gmail.com")
	var email = ServerConnection.get_last_email()
	print(email)
	# 创建UI系统
	#var ui = UICanvas.new()
	#add_child(ui)
	## 添加主菜单
	#var main_menu = preload("res://src/ui/LoginForm.tscn").instantiate()
	#ui.add_ui(main_menu)
	#ui.set_ui_visibility(false)
	#ui.set_ui_visibility(true)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	pass
