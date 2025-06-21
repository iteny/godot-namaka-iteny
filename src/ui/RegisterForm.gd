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
		rich_text_label.text = "Email cannot be empty"
		return
	elif password_input.text.is_empty() or password_input_re.text.is_empty():
		rich_text_label.text = "Password cannot be empty"
		return
	elif password_input.text.similarity(password_input_re.text) != 1:
		rich_text_label.text = "Passwords do not match"
		return
	register_pressed.emit(email_input.text,password_input.text)
	#emit_signal("register_pressed", email_input.text, password_input.text, remember_email.pressed)

func _on_register_button_pressed() -> void:
	attempt_register()
	print("我要正式注册了")
	pass # Replace with function body.
