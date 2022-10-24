extends Node

onready var chatLog = get_node("VBoxContainer/RichTextLabel")

var groups = [
	{'name': 'self', 'color': '#ebdb34'},
	{'name': 'remote', 'color': '#34c5f1'},
	{'name': 'system', 'color': '#eb4034'}
]

var groupIndex = 0
var playerName = 'player'


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func addMessage(player, text, group =0):
	chatLog.bbcode_text += '\n'
	chatLog.bbcode_text += '[color=' + groups[group]['color'] +']'
	chatLog.bbcode_text += player
	chatLog.bbcode_text += '[/color] '
	chatLog.bbcode_text += '[color=#ffffff]'
	chatLog.bbcode_text += text
	chatLog.bbcode_text += '[/color]'
