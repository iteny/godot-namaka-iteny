extends Node2D

@onready var login_form = $CanvasLayer/LoginForm # 
@onready var scene_container = $CanvasLayer/LoginForm  # 子场景容器节点

#@onready var login_form: LoginForm = $CanvasLayer/LoginForm

var current_scene: Node = null  # 当前显示的子场景
var ui:UICanvas
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ServerConnection.save_email("iteny@gmail.com")
	var email = ServerConnection.get_last_email()
	print(email)
	# 创建UI系统
	#var ui = UICanvas.new()
	#ui = UICanvas.new()
	#add_child(ui)
	### 添加主菜单
	#var main_menu = preload("res://src/ui/LoginForm.tscn").instantiate()
	#ui.add_ui(main_menu)
	#ui.set_ui_visibility(false)
	#ui.set_ui_visibility(true)
	#login_form.hide()
	login_form.goto_register.connect(_on_loginform_sings)
	#print(login_form.goto_register.connect())
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#打印场景内存占用
	if Engine.get_frames_drawn()==100:
		print("内存占用:",OS.get_static_memory_peak_usage()/1024/1024,"mb")
	pass
func _on_loginform_sings():
	change_scene_with_fade("res://src/ui/RegisterForm.tscn")
func change_scene_with_fade(path:String)->void:
	#layer=10	
	print("111")
	login_form.show()
	var tween:=create_tween()
	tween.tween_property(login_form,"modulate:a",1.0,0.2)
	await tween.finished
	print("222")
	await change_scene_async(path)
	var tween_out:=create_tween()
	tween_out.tween_property(login_form,"modulate:a",0.0,0.3)
	await tween.finished
	login_form.hide()
	print("222")
#异步加载
func change_scene_async(path:String)->void:
	ResourceLoader.load_threaded_request(path)
	while ResourceLoader.load_threaded_get_status(path)==ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		await get_tree().create_timer(0.05).timeout
	if ResourceLoader.load_threaded_get_status(path)==ResourceLoader.THREAD_LOAD_LOADED:
		get_tree().change_scene_to_packed(ResourceLoader.load_threaded_get(path))
		
