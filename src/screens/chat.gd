extends CanvasLayer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_submit_pressed():
	print('Submit pressed to submit chat')
	if $chat.text != '':
		Network.chat($chat.text)
		get_node("../room/Player/TypingBubble").visible = false
		get_node("../room/Player/ChatBubble2").visible = true


func _on_chat_text_entered(message: String):
	print('enter key pressed to submit chat')
	if $chat.text != '':
		get_node('Chatbox').addMessage('player',$chat.text)
		get_node('../room/Player').chat($chat.text)
		Network.chat($chat.text)
		$chat.text = ''
		get_node("../room/Player/TypingBubble").visible = false
		get_node("../room/Player/ChatBubble2").visible = true


func _on_chat_text_changed(new_text):
	get_node("../room/Player/TypingBubble").visible = true
	get_node("../room/Player/ChatBubble2").visible = false
	get_node("../room/Player/ChatBubble").text = ''
	get_node("../room/Player/TypingTimer").start(2)
	Network.is_thinking()

