extends Node


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
