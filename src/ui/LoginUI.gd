extends Control

# 登录界面脚本
# 包含动画效果、交互反馈和视觉美化

# 定义颜色常量
const PRIMARY_COLOR = Color("#4361ee")
const SECONDARY_COLOR = Color("#f72585")
const BG_COLOR = Color("#03045e")
const TEXT_COLOR = Color("#e9ecef")
const PLACEHOLDER_COLOR = Color("#adb5bd")
const ERROR_COLOR = Color("#e63946")
const PANEL_COLOR = Color("#1b263b")

# 节点引用
@onready var username_field = $LoginPanel/VBoxContainer/UsernameContainer/UsernameField
@onready var password_field = $LoginPanel/VBoxContainer/PasswordContainer/PasswordField
@onready var login_button = $LoginPanel/VBoxContainer/LoginButton
@onready var remember_check = $LoginPanel/VBoxContainer/RememberContainer/RememberCheck
@onready var error_label = $LoginPanel/VBoxContainer/ErrorLabel
@onready var login_panel = $LoginPanel
@onready var welcome_label = $WelcomeLabel
@onready var loading_animation = $LoadingAnimation
@onready var bg_particles = $BGParticles

func _ready():
	# 初始设置 - 使用 RenderingServer 设置背景颜色
	RenderingServer.set_default_clear_color(BG_COLOR)
	
	# 应用所有样式
	apply_styles()
	
	# 连接信号
	login_button.pressed.connect(_on_login_button_pressed)
	username_field.text_changed.connect(_on_field_changed)
	password_field.text_changed.connect(_on_field_changed)
	
	# 初始动画
	animate_login_panel_enter()
	
	# 开始粒子动画
	bg_particles.emitting = true

# 应用所有UI样式
func apply_styles():
	# 应用面板样式
	login_panel.add_theme_stylebox_override("panel", create_panel_stylebox())
	
	# 应用标题样式
	if has_node("LoginPanel/VBoxContainer/TitleLabel"):
		var title_label = $LoginPanel/VBoxContainer/TitleLabel
		title_label.add_theme_font_size_override("font_size", 32)
		title_label.add_theme_color_override("font_color", TEXT_COLOR)
	
	# 应用输入框样式
	username_field.add_theme_stylebox_override("normal", create_field_stylebox())
	username_field.add_theme_stylebox_override("focus", create_field_focus_stylebox())
	username_field.add_theme_color_override("font_color", TEXT_COLOR)
	username_field.add_theme_color_override("font_placeholder_color", PLACEHOLDER_COLOR)
	username_field.add_theme_constant_override("minimum_character_width", 20)
	
	password_field.add_theme_stylebox_override("normal", create_field_stylebox())
	password_field.add_theme_stylebox_override("focus", create_field_focus_stylebox())
	password_field.add_theme_color_override("font_color", TEXT_COLOR)
	password_field.add_theme_color_override("font_placeholder_color", PLACEHOLDER_COLOR)
	password_field.add_theme_constant_override("minimum_character_width", 20)
	password_field.secret = true
	
	# 应用按钮样式
	_update_login_button_state()
	
	# 应用错误标签样式
	error_label.add_theme_color_override("font_color", ERROR_COLOR)
	
	# 应用记住我标签样式
	if has_node("LoginPanel/VBoxContainer/RememberContainer/RememberLabel"):
		var remember_label = $LoginPanel/VBoxContainer/RememberContainer/RememberLabel
		remember_label.add_theme_color_override("font_color", TEXT_COLOR)
	
	# 应用欢迎标签样式
	welcome_label.add_theme_font_size_override("font_size", 36)
	welcome_label.add_theme_color_override("font_color", TEXT_COLOR)

# 登录面板进入动画
func animate_login_panel_enter():
	# 初始状态
	login_panel.scale = Vector2(0.8, 0.8)
	login_panel.modulate = Color.TRANSPARENT
	login_panel.position = Vector2(login_panel.position.x, login_panel.position.y + 100)
	
	# 创建动画
	var tween = create_tween().set_parallel(true)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	
	# 缩放动画
	tween.tween_property(login_panel, "scale", Vector2(1, 1), 0.8)
	
	# 透明度动画
	tween.tween_property(login_panel, "modulate", Color.WHITE, 0.6)
	
	# 位置动画
	tween.tween_property(login_panel, "position:y", login_panel.position.y - 100, 0.7)

# 输入框内容变化时处理
func _on_field_changed(_new_text):
	# 如果有错误信息则清除
	if error_label.text != "":
		error_label.text = ""
		error_label.modulate = Color.TRANSPARENT
		
		# 恢复输入框颜色
		username_field.add_theme_stylebox_override("normal", create_field_stylebox())
		password_field.add_theme_stylebox_override("normal", create_field_stylebox())
	
	# 更新登录按钮状态
	_update_login_button_state()

# 更新登录按钮状态
func _update_login_button_state():
	var is_valid = username_field.text.length() > 0 && password_field.text.length() > 0
	login_button.disabled = !is_valid
	
	# 按钮动画效果
	if is_valid:
		login_button.add_theme_stylebox_override("normal", create_button_stylebox(PRIMARY_COLOR))
		login_button.add_theme_stylebox_override("hover", create_button_stylebox(PRIMARY_COLOR.lightened(0.2)))
		login_button.add_theme_stylebox_override("pressed", create_button_stylebox(PRIMARY_COLOR.darkened(0.1)))
	else:
		login_button.add_theme_stylebox_override("normal", create_button_stylebox(Color("#6c757d")))
		login_button.add_theme_stylebox_override("hover", create_button_stylebox(Color("#6c757d")))
		login_button.add_theme_stylebox_override("pressed", create_button_stylebox(Color("#6c757d")))
	
	# 设置按钮文本样式
	login_button.add_theme_color_override("font_color", TEXT_COLOR)
	login_button.add_theme_color_override("font_hover_color", TEXT_COLOR)
	login_button.add_theme_color_override("font_pressed_color", TEXT_COLOR)
	login_button.add_theme_color_override("font_disabled_color", PLACEHOLDER_COLOR)
	login_button.add_theme_font_size_override("font_size", 18)

# 登录按钮按下处理
func _on_login_button_pressed():
	# 获取输入
	var username = username_field.text.strip_edges()
	var password = password_field.text
	
	# 简单验证
	if username.length() < 3:
		show_error("用户名至少需要3个字符")
		animate_field_error(username_field)
		return
	
	if password.length() < 6:
		show_error("密码至少需要6个字符")
		animate_field_error(password_field)
		return
	
	# 显示加载动画
	loading_animation.visible = true
	login_button.disabled = true
	
	# 模拟登录过程（实际项目中替换为真实登录逻辑）
	await get_tree().create_timer(1.5).timeout
	
	# 登录成功处理
	login_success(username)

# 显示错误信息
func show_error(message):
	error_label.text = message
	error_label.modulate = Color.WHITE
	
	# 错误信息动画
	var tween = create_tween()
	tween.tween_property(error_label, "modulate", Color(1, 1, 1, 1), 0.3)

# 输入框错误动画
func animate_field_error(field):
	# 保存原始样式
	var original_style = create_field_stylebox()
	
	# 创建错误样式
	var error_style = create_field_stylebox()
	error_style.border_color = ERROR_COLOR
	error_style.border_width_left = 2
	error_style.border_width_right = 2
	error_style.border_width_top = 2
	error_style.border_width_bottom = 2
	
	# 应用错误样式
	field.add_theme_stylebox_override("normal", error_style)
	
	# 震动动画
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(field, "position:x", field.position.x + 5, 0.05)
	tween.tween_property(field, "position:x", field.position.x - 5, 0.05)
	tween.tween_property(field, "position:x", field.position.x + 5, 0.05)
	tween.tween_property(field, "position:x", field.position.x, 0.05)
	
	# 延迟后恢复样式
	await tween.finished
	await get_tree().create_timer(0.5).timeout
	field.add_theme_stylebox_override("normal", original_style)

# 登录成功处理
func login_success(username):
	# 隐藏登录面板
	var tween = create_tween().set_parallel(true)
	tween.tween_property(login_panel, "modulate", Color.TRANSPARENT, 0.5)
	tween.tween_property(login_panel, "scale", Vector2(0.8, 0.8), 0.5)
	
	# 显示欢迎信息
	welcome_label.text = "欢迎回来, %s!" % username
	welcome_label.modulate = Color.TRANSPARENT
	welcome_label.visible = true
	
	# 欢迎信息动画
	var welcome_tween = create_tween().set_parallel(true)
	welcome_tween.tween_property(welcome_label, "modulate", Color.WHITE, 1.0).set_delay(0.5)
	welcome_tween.tween_property(welcome_label, "position:y", welcome_label.position.y - 50, 1.0).set_delay(0.5)
	
	# 隐藏加载动画
	loading_animation.visible = false
	
	# 停止粒子动画
	bg_particles.emitting = false

# 创建按钮样式
func create_button_stylebox(color: Color) -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = color
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.border_width_bottom = 2
	style.border_color = color.darkened(0.2)
	style.shadow_color = Color(0, 0, 0, 0.2)
	style.shadow_size = 4
	style.content_margin_left = 20
	style.content_margin_right = 20
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	return style

# 创建输入框样式
func create_field_stylebox() -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = Color("#0d1b2a")
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.border_width_bottom = 2
	style.border_color = PRIMARY_COLOR
	style.content_margin_left = 10
	style.content_margin_right = 10
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	return style

# 创建输入框聚焦样式
func create_field_focus_stylebox() -> StyleBoxFlat:
	var style = create_field_stylebox()
	style.border_color = PRIMARY_COLOR.lightened(0.3)
	style.border_width_bottom = 3
	return style

# 创建面板样式
func create_panel_stylebox() -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = PANEL_COLOR
	style.corner_radius_top_left = 16
	style.corner_radius_top_right = 16
	style.corner_radius_bottom_left = 16
	style.corner_radius_bottom_right = 16
	style.border_width_bottom = 2
	style.border_color = PRIMARY_COLOR
	style.shadow_color = Color(0, 0, 0, 0.3)
	style.shadow_size = 10
	style.content_margin_left = 20
	style.content_margin_right = 20
	style.content_margin_top = 20
	style.content_margin_bottom = 20
	return style
