extends Node2D
class_name ssj
@onready var login_form = $CanvasLayer/LoginForm # 
@onready var scene_container = $CanvasLayer/LoginForm  # 子场景容器节点
#@onready var login_form: LoginForm = $CanvasLayer/LoginForm
var current_scene: Node = null  # 当前显示的子场景
var ui:UICanvas
# Nakama 客户端配置
# 导入 Nakama
#const Nakama = preload("res://addons/com.heroiclabs.nakama/Nakama.gd")
#var _client : NakamaClient
#var session : NakamaSession
#var _socket: NakamaSocket
#const SERVER_KEY = "defaultkey"  # 默认服务器密钥
#const SERVER_ADDRESS = "127.0.0.1" # 服务器地址
#const SERVER_PORT = 7350 # 默认端口
#const SERVER_SCHEME = "http"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ServerConnection.save_email("iteny@gmail.com")
	var email = ServerConnection.get_last_email()
	print(email)
	# 初始化客户端
	#_client = Nakama.create_client(SERVER_KEY, SERVER_ADDRESS, SERVER_PORT, SERVER_SCHEME)
	
	login_form.goto_register.connect(_on_loginform_to_registerform)
	login_form.login_pressed.connect(_on_login)
	#logout()
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
	#var result = await _client.authenticate_email_async(email, password, null, true)
	var result :=await ServerConnection.register_async(email, password)
	if result.is_exception():
		var error = result.get_exception()
		cb.call("注册失败: %s" % error.message,2)
	else:
		var session = result
		cb.call("注册成功！ID: %s" % session.user_id,1)
		await get_tree().create_timer(3.0).timeout 
		replace_child_node(target_node, new_node)
func _on_login(email:String,password:String,cb: Callable):
	#var result = await _client.authenticate_email_async(email, password)
	var result :=await ServerConnection.login_async(email, password)
	if result.is_exception():
		cb.call("登录失败: %s" % result.get_exception().message,2)
	else:
		ServerConnection.session = result
		cb.call("登录成功！Token: %s" % ServerConnection.session.token,1)
		#connect_to_socket()
		ServerConnection.connect_to_socket()
		change_scene_with_fade("res://src/game/MainGame.tscn")
	#var account = await _client.get_account_async(session)
	##if account.is_exception():
		##var exception = account.get_exception()
		##push_error("获取账户信息失败: " + exception.message)
		##return null
	#var username = account.user.username
	#var avatar_url = account.user.avatar_url
	#var user_id = account.user.id	
	#print("天菩萨："+username+avatar_url+user_id)
	print("123123123")
#func connect_to_socket():
	#_socket = Nakama.create_socket_from(_client)
	#var result = await _socket.connect_async(session)
	#if result.is_exception():
		#print("Socket连接失败: ", result.get_exception().message)
	#else:
		#print("Socket连接成功!")
## 退出账号
#func logout():
	## 如果socket连接存在，则关闭
	#if _socket != null and _socket.is_connected_to_host():
		#await _socket.close_async()
		#print("已断开socket连接")
	#
	## 清除session和socket
	#session = null
	#_socket = null
	#print("已退出账号")
# 邮箱登录
#func _on_email_login_button_pressed():
	#var email = email_input.text.strip_edges()
	#var password = password_input.text
	#
	#if email.is_empty() or password.is_empty():
		#result_label.text = "请输入邮箱和密码"
		#return
	#
	#result_label.text = "登录中..."
	#
	#try_login(async func():
		#nakama_session = await nakama_client.authenticate_email_async(email, password)
		#update_ui_state()
		#result_label.text = "邮箱登录成功！用户ID: %s" % nakama_session.user_id
	#)
	
func change_scene_with_fade(path:String)->void:
	#layer=10	
	login_form.show()
	var tween:=create_tween()
	tween.tween_property(login_form,"modulate:a",1.0,0.2)
	await tween.finished
	await change_scene_async(path)
	var tween_out:=create_tween()
	tween_out.tween_property(login_form,"modulate:a",0.0,0.3)
	await tween.finished
	login_form.hide()
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
