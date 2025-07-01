extends Node
signal chat_message_received_signal(username,text)
const SERVER_KEY = "defaultkey"  # 默认服务器密钥
const SERVER_ADDRESS = "127.0.0.1" # 服务器地址
const SERVER_PORT = 7350 # 默认端口
const SERVER_SCHEME = "http"
var _client := Nakama.create_client(SERVER_KEY, SERVER_ADDRESS, SERVER_PORT, SERVER_SCHEME)
var _socket: NakamaSocket 
var session: NakamaSession
var world_channel_id: String
func _ready() -> void:
	#_client = Nakama.create_client(SERVER_KEY, SERVER_ADDRESS, SERVER_PORT, SERVER_SCHEME)
	pass
	
	
#异步注册
func register_async(email:String,password:String)->NakamaSession:
	var result = await _client.authenticate_email_async(email, password, null, true)
	return result
#异步登录
func login_async(email:String,password:String)->NakamaSession:
	var result = await _client.authenticate_email_async(email, password)
	if result.is_exception():
		print("登录失败")
	else:
		print("登录陈工")
		#connect_to_socket()
	return result
 # 连接实时Socket
func connect_to_socket():
	_socket = Nakama.create_socket_from(_client)
	var result = await _socket.connect_async(session)
	if result.is_exception():
		print("Socket连接失败: ", result.get_exception().message)
	else:
		print("Socket连接成功!")
	# 设置消息接收监听
	_socket.received_channel_message.connect(_on_received_message)
	# 加入世界聊天室
	join_world_chat_room()
func _on_received_message(message: NakamaAPI.ApiChannelMessage):
	# 解析消息内容
	var content = JSON.parse_string(message.content)
	var _sender = message.sender_id
	var username = message.username
	
	# 显示在UI中
	var formatted_msg = "[%s]: %s" % [username, content]
	#chat_log.append_text(formatted_msg + "\n")
	chat_message_received_signal.emit(username,content.message)
	print("收到消息: ", formatted_msg)
#获取账号信息
func get_account():
	var account = await _client.get_account_async(session)
	#if account.is_exception():
		#var exception = account.get_exception()
		#push_error("获取账户信息失败: " + exception.message)
		#return null
	var username = account.user.username
	var avatar_url = account.user.avatar_url
	var user_id = account.user.id	
	print("天天开心"+username+avatar_url+user_id)
#更新账户信息
func  update_account_info():
	var new_username = "NotTheImp0ster"
	var new_display_name = "Innocent Dave"
	var new_avatar_url = "https://example.com/imposter.png"
	var new_lang_tag = "en"
	var new_location = "Edinburgh"
	var new_timezone = "CST"

	# 直接等待异步函数完成
	await _client.update_account_async(
		session,
		new_username,
		new_display_name,
		new_avatar_url,
		new_lang_tag,
		new_location,
		new_timezone
	)
#获取其他玩家的公开信息
func get_other_player():
	var ids = ["userid1", "userid2"]
	var users: NakamaAPI.ApiUsers = await _client.get_users_async(session, ids)
	pass	
#读取元数据
func get_metadata():
	var _title: String
	var _hat: String
	var _skin: String
	# Get the updated account object
	var account_result = await _client.get_account_async(session)
	if account_result.is_exception():
		push_error("Failed to get account: " + str(account_result.get_exception()))
		return
	var account: NakamaAPI.ApiAccount = account_result
	# Parse the account user metadata
	var json = JSON.new()
	var parse_error = json.parse(account.user.metadata)
	if parse_error != OK:
		push_error("JSON parse error: " + json.get_error_message())
		return
	var metadata = json.get_data()
	print("Title: %s" % metadata.get("title", ""))
	print("Hat: %s" % metadata.get("hat", ""))
	print("Skin: %s" % metadata.get("skin", ""))
	pass
#创建群组
func create_group():
	var group_name = "world_channel"
	var description = "A group for people who love playing the imposter."
	var open = true # public group
	var max_size = 10000
	var _group : NakamaAPI.ApiGroup =await _client.create_group_async(session, group_name, description, open, max_size)
#加入聊天室
func join_world_chat_room():
	var roomname = "world "
	var persistence = false
	var hidden = false
	var type = NakamaSocket.ChannelType.Room
	var channel : NakamaRTAPI.Channel =await _socket.join_chat_async(roomname, type, persistence, hidden)
	if channel.is_exception():
		var error = channel.get_exception().message
		print("加入聊天室失败: " + error)
		return
	print("Connected to dynamic room channel: '%s'" % [channel])
	world_channel_id = channel.id
#发送消息
func send_room_message(mess:String):
	var channel_id = world_channel_id
	#print("我的房间号："+channel_id)
	if channel_id == "":
		printerr("无法向聊天发送文本消息：缺少channel_id")
		return 
	var message_content = { "message": mess }

	var message_ack : NakamaRTAPI.ChannelMessageAck = await _socket.write_chat_message_async(channel_id, message_content)
	if message_ack.is_exception():
		var error = message_ack.get_exception().message
		print("发送信息:"+error)
		return
	#var emote_content = {
		#"emote": "point",
		#"emoteTarget": "<red_player_user_id>",
		#}
#
	#var emote_ack : NakamaRTAPI.ChannelMessageAck = await _socket.write_chat_message_async(channel_id, emote_content)
	pass
# 将邮件保存到配置文件中res://config.ini
func save_email(email: String) -> void:
	EmailConfigWorker.save_email(email)


# 从配置文件获取key为last_email的email，或一个空字符串
func get_last_email() -> String:
	return EmailConfigWorker.get_last_email()


# 从配置文件中删除最后last_email
func clear_last_email() -> void:
	EmailConfigWorker.clear_last_email()


# 保存登录参数到config.ini文件内
class EmailConfigWorker:
	const CONFIG := "res://config.ini"
	# 将邮件保存到配置文件中
	static func save_email(email: String) -> void:
		var file := ConfigFile.new()
		file.load(CONFIG)
		file.set_value("connection", "last_email", email)
		file.save(CONFIG)
	# 从配置文件获取key为last_email的email，或一个空字符串
	static func get_last_email() -> String:
		var file := ConfigFile.new()
		file.load(CONFIG)
		if file.has_section_key("connection", "last_email"):
			return file.get_value("connection", "last_email")
		else:
			return ""
	# 从配置文件中删除最后last_email
	static func clear_last_email() -> void:
		var file := ConfigFile.new()
		file.load(CONFIG)
		file.set_value("connection", "last_email", "")
		file.save(CONFIG)
