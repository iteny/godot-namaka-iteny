extends Node2D
#var _client : NakamaClient
#
#var _socket: NakamaSocket
#const SERVER_KEY = "defaultkey"  # 默认服务器密钥
#const SERVER_ADDRESS = "127.0.0.1" # 服务器地址
#const SERVER_PORT = 7350 # 默认端口
#const SERVER_SCHEME = "http"
# 初始化Nakama
func _ready():
	#var scriptA_node = get_node("/root/Main")
	#scriptA_node.session
	#_client = Nakama.create_client(SERVER_KEY, SERVER_ADDRESS, SERVER_PORT, SERVER_SCHEME)
	#var account = await ServerConnection.get_account_async(ServerConnection.session)
	##if account.is_exception():
		##var exception = account.get_exception()
		##push_error("获取账户信息失败: " + exception.message)
		##return null
	#var username = account.user.username
	#var avatar_url = account.user.avatar_url
	#var user_id = account.user.id	
	#print("天天开心"+username+avatar_url+user_id)
	#ServerConnection.get_account()
	var username:=ServerConnection.session.username
	print(username+"呸呸呸")
	#ServerConnection.update_account_info()
	#ServerConnection.get_metadata()
	#ServerConnection.create_group()
	#ServerConnection.add_room()
	#await get_tree().create_timer(3.0).timeout 
	#ServerConnection.send_room_message("你好吗，小图在吗")
	pass
func _process(delta: float) -> void:
	pass
	
