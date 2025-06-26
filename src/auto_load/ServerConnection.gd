extends Node
const SERVER_KEY = "defaultkey"  # 默认服务器密钥
const SERVER_ADDRESS = "127.0.0.1" # 服务器地址
const SERVER_PORT = 7350 # 默认端口
const SERVER_SCHEME = "http"
var _client : NakamaClient
var _socket: NakamaSocket 
var session: NakamaSession
func _ready() -> void:
	_client = Nakama.create_client(SERVER_KEY, SERVER_ADDRESS, SERVER_PORT, SERVER_SCHEME)
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
func connect_to_socket():
	_socket = Nakama.create_socket_from(_client)
	var result = await _socket.connect_async(session)
	if result.is_exception():
		print("Socket连接失败: ", result.get_exception().message)
	else:
		print("Socket连接成功!")
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
