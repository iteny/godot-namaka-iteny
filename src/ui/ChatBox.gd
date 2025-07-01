extends Control
@onready var chat_log: RichTextLabel = $ScrollContainer/ChatLog

#@onready var rich_text_label: RichTextLabel = $ScrollContainer/RichTextLabel
@onready var line_edit: LineEdit = $HBoxContainer/LineEdit
var format_count := 0
# Number of replies stored in the chat history
const HISTORY_LENGTH := 20
var user_color := Color.GREEN
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ServerConnection.chat_message_received_signal.connect(_received_world_room_message)
	#ServerConnection.send_room_message("欢迎来世界频道")
	#pass # Replace with function body.
#
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass

func send_chat_message(mes:String):
	#print("我发送了哦"+mes)
	ServerConnection.send_room_message(mes)
	#ServerConnection.chat_message_received.connect(_jsdflk)
	#if not ServerConnection.chat_message_received_signal.is_connected(_received_world_room_message):
	#ServerConnection.chat_message_received_signal.connect(_received_world_room_message)
func _on_send_button_pressed() -> void:
	var messg = line_edit.text
	send_chat_message(messg)
	pass # Replace with function body.
func _received_world_room_message(username,text):
	#print("撒到付件阿是")
	#print(text)
	#chat_log.text = username+":"+text
	format_chat_message(text,username,user_color)
	pass
func format_chat_message(text:String,sender_name:String,color:Color)->void:
	chat_log.bbcode_enabled = true
	if format_count == HISTORY_LENGTH:
		chat_log.text = chat_log.text.substr(chat_log.text.find("\n"))
	else:
		format_count += 1
	chat_log.text += (
		"\n[color=#%s]%s[/color]: %s"
		% [color.to_html(false), sender_name, text]
	)
	
