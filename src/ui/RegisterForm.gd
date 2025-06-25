extends Control
class_name RegisterForm
signal register_pressed(email:String,password:String)
@onready var email_input = $menu/BoxEmail/EmailInput
@onready var password_input = $menu/BoxPassword/PasswordInput
@onready var password_input_re = $menu/BoxRepeat/PasswordInputRe
@onready var rich_text_label = $menu/RichTextLabel


## Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#pass # Replace with function body.
#
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
func attempt_register() -> void:
	if email_input.text.is_empty():
		show_message("邮箱不能为空",2)
		return
	elif password_input.text.is_empty() or password_input_re.text.is_empty():
		show_message("密码不能为空",2)
		return
	elif password_input.text.length() < 7:
		show_message("密码长度至少8位", 2)
		return
	elif password_input.text.similarity(password_input_re.text) != 1:
		show_message("两次密码输入不一致",2)
		return
	if ValidData.is_valid_email(email_input.text) == false:
		show_message("Email格式错误！",2)
		return
	register_pressed.emit(email_input.text,password_input.text,Callable(self,"show_message"))
	#emit_signal("register_pressed", email_input.text, password_input.text, remember_email.pressed)
func show_message(text: String, statusType: int):
	# 清空内容
	rich_text_label.clear()
	var style = StyleBoxFlat.new()
	#如果类型为1为成功，2为失败
	if statusType == 1:
		style.bg_color = "#51a351"  # RGB 值 (深蓝色)
		style.set_corner_radius_all(5) 
		rich_text_label.append_text("[img=20x20]res://assets/icons/success.svg[/img] "+text)
	elif statusType == 2:
		style.bg_color = "#bd362f"  # RGB 值 (深蓝色)
		style.set_corner_radius_all(5) 
		rich_text_label.append_text("[img=20x20]res://assets/icons/fail.svg[/img] "+text)
	rich_text_label.add_theme_stylebox_override("normal", style)
func _on_register_button_pressed() -> void:
	attempt_register()
	print("我要正式注册了")
	pass # Replace with function body.
