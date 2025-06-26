extends Control
class_name LoginForm
signal login_pressed(email:String,password:String)
signal goto_register
@onready var email_input: LineEdit = $menu/BoxEmail/EmailInput
@onready var password_input: LineEdit = $menu/BoxPassword/PasswordInput
@onready var check_box: CheckBox = $menu/BoxCheck/CheckBox
@onready var status_label: RichTextLabel = $menu/StatusLabel

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
#执行登录
func execute_login() -> void:
	if email_input.text.is_empty():
		show_message("邮箱不能为空",2)
		return
	elif password_input.text.is_empty():
		show_message("密码不能为空",2)
		return
	elif password_input.text.length() < 7:
		show_message("密码长度至少8位", 2)
		return
	
	if ValidData.is_valid_email(email_input.text) == false:
		show_message("Email格式错误！",2)
		return
	login_pressed.emit(email_input.text,password_input.text,Callable(self,"show_message"))
func show_message(text: String, statusType: int):
	# 清空内容
	status_label.clear()
	var style = StyleBoxFlat.new()
	#如果类型为1为成功，2为失败
	if statusType == 1:
		style.bg_color = "#51a351"  # RGB 值 (深蓝色)
		style.set_corner_radius_all(5) 
		status_label.append_text("[img=20x20]res://assets/icons/success.svg[/img] "+text)
	elif statusType == 2:
		style.bg_color = "#bd362f"  # RGB 值 (深蓝色)
		style.set_corner_radius_all(5) 
		status_label.append_text("[img=20x20]res://assets/icons/fail.svg[/img] "+text)
	status_label.add_theme_stylebox_override("normal", style)
func _on_register_button_pressed() -> void:
	goto_register.emit()
	pass # Replace with function body.


func _on_login_button_pressed() -> void:
	execute_login()
	pass # Replace with function body.
