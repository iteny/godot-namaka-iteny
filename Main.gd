extends Node2D

@onready var login_form = $CanvasLayer/LoginForm # 
@onready var scene_container = $CanvasLayer/LoginForm  # 子场景容器节点
#@onready var login_form: LoginForm = $CanvasLayer/LoginForm
var current_scene: Node = null  # 当前显示的子场景
var ui:UICanvas
# Nakama 客户端配置
var client : NakamaClient
var session : NakamaSession
const SERVER_KEY = "defaultkey"  # 默认服务器密钥
const SERVER_ADDRESS = "127.0.0.1" # 服务器地址
const SERVER_PORT = 7350 # 默认端口
const SERVER_SCHEME = "http"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ServerConnection.save_email("iteny@gmail.com")
	var email = ServerConnection.get_last_email()
	print(email)
	# 初始化客户端
	client = Nakama.create_client(SERVER_KEY, SERVER_ADDRESS, SERVER_PORT, SERVER_SCHEME)
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
	login_form.goto_register.connect(_on_loginform_to_registerform)
	#registerform.register_pressed.connect()
	#play_node.register_pressed.connect()
	# 创建新节点（可以是实例化场景或新建节点）
	
	# 替换场景中名为 "Player" 的节点
	#replace_node("%LoginForm", new_player)
	
	#print(login_form.goto_register.connect())
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#打印场景内存占用
	if Engine.get_frames_drawn()==100:
		print("内存占用:",OS.get_static_memory_peak_usage()/1024/1024,"mb")
	pass
#切换场景
func _on_change_scene():
	change_scene_with_fade("res://src/ui/RegisterForm.tscn")
#登录框替换成注册框
func _on_loginform_to_registerform():
	var new_node = preload("res://src/ui/RegisterForm.tscn").instantiate()
	var target_node = get_node("/root/Main/CanvasLayer/LoginForm")	
	new_node.register_pressed.connect(Callable(self, "_on_register").bind())
	replace_child_node(target_node, new_node)
func _on_register(email:String,password:String,cb: Callable):
	print("账号密码分别是:"+email+password)
	var new_node = preload("res://src/ui/LoginForm.tscn").instantiate()
	var target_node = get_node("/root/Main/CanvasLayer/RegisterForm")	
	new_node.goto_register.connect(_on_loginform_to_registerform)
	 # 使用正确的认证方法进行注册
	var result = await client.authenticate_email_async(email, password, null, true)
	if result.is_exception():
		var error = result.get_exception()
		cb.call("注册失败: %s" % error.message,2)
		#register_node.show_message("注册失败: %s" % error.message,2)
		#register_node.rich_text_label.text = "注册失败: %s" % error.message
	else:
		session = result
		#register_node.show_message("注册成功！ID: %s" % session.user_id,1)
		#register_node.rich_text_label.text = "注册成功！ID: %s" % session.user_id
		cb.call("注册成功！ID: %s" % session.user_id,1)
		#replace_child_node(target_node, new_node)
	print("老卵")	

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
		#get_tree().change_scene_to_packed(ResourceLoader.load_threaded_get(path))
		var packed_scene=ResourceLoader.load_threaded_get(path)
		var scene=packed_scene.instantiate()
		get_tree().root.add_child(scene)
		get_tree().current_scene.queue_free()
		get_tree().current_scene=scene
		
# 假设在当前节点脚本中操作
func replace_node(target_path: NodePath, new_node: Node):
	# 获取目标节点和其父节点
	var target_node = get_node(target_path)
	var parent = target_node.get_parent()
	
	# 记录目标节点的位置和属性（根据需要扩展）
	var index = target_node.get_index()
	var name = target_node.name
	var transform = target_node.global_transform  # 如果是2D用 global_transform
	
	# 移除旧节点
	parent.remove_child(target_node)
	target_node.queue_free()
	
	# 添加新节点到相同位置
	new_node.name = name
	parent.add_child(new_node)
	parent.move_child(new_node, index)
	
	# 恢复关键属性
	new_node.global_transform = transform  # 如果是2D用 global_transform
	# 可根据需要复制其他属性（如脚本变量等）
# 替换场景中的某一个节点
func replace_child_node(target_node: Node, new_node: Node):
	# 获取父节点
	var parent = target_node.get_parent()
	# 记录位置索引
	var index = target_node.get_index()
	# 添加新节点并移动到相同位置
	parent.add_child(new_node)
	parent.move_child(new_node, index)
	# 移除旧节点
	target_node.queue_free()
# 查找直接子节点
func find_child_by_name(parent: Node, name: String) -> Node:
	for child in parent.get_children():
		if child.name == name:
			return child
	return null
