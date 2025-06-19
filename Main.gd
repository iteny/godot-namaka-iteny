extends Node2D

@onready var login_form = $CanvasLayer/LoginForm # 
@onready var scene_container = $CanvasLayer/LoginForm  # 子场景容器节点

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
	login_form.goto_register.connect(_on_loginform_sings)
	#print(login_form.goto_register.connect())
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	pass
func _on_loginform_sings():
	#ui = UICanvas.new()
	#ui.switch_ui(preload("res://src/ui/RegisterForm.tscn"), UICanvas.UI_LAYER.DEFAULT)
	#var root = get_tree().get_node("canvas") # 假设根节点名为Root
#
	#root.load_scene("res://src/ui/RegisterForm.tscn")
	
	load_sub_scene("res://src/ui/RegisterForm.tscn")
	#remove_child_scene()
	#get_tree().change_scene_to_file("res://src/ui/RegisterForm.tscn")
	print("Signal 'sings' received from LoginForm!")
	
# 加载子场景
func load_sub_scene(scene_path: String):
	# 卸载当前场景
	if current_scene:
		current_scene.queue_free()
	
	# 加载新场景
	var new_scene = load(scene_path).instantiate()
	scene_container.add_child(new_scene)
	current_scene = new_scene
	
	# 连接返回按钮信号（如果存在）
	if new_scene.has_method("back_to_main"):
		new_scene.connect("back_to_main", Callable(self, "_on_back_to_main"))
func remove_child_scene():
	# 1. 获取要移除的场景引用
	var scene_to_remove = $CanvasLayer/LoginForm
	
	# 2. 从父节点移除
	remove_child(scene_to_remove)
	
	# 3. 安全释放资源
	scene_to_remove.queue_free()
