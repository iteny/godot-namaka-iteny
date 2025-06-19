extends Control
class_name LoginForm

signal goto_register
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#var login_form = get_node("LoginForm")
	#if login_form and login_form.has_signal("goto_register"):
		#login_form.
	#else:
		#print("信号不存在")
		#push_error("信号 'sings' 不存在于 LoginForm 节点")

	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_register_button_pressed() -> void:
	#goto_register.emit()
	#emit_signal("goto_register")
	goto_register.emit()
	print("跳转到注册页面")
	pass # Replace with function body.
