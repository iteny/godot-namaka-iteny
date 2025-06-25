extends Node


# 邮箱格式验证函数
func is_valid_email(email: String) -> bool:
	# 使用正则表达式验证邮箱格式
	var regex = RegEx.new()
	
	# 编译正则表达式 - 覆盖大多数常见邮箱格式
	regex.compile("^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)+$")
	
	return regex.search(email) != null
