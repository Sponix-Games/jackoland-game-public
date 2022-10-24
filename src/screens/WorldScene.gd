extends Node2D


export (String) var room = 'town'
var _roomInstance = null


# Called when the node enters the scene tree for the first time.
func _ready():
	_roomInstance = load("res://src/screens/rooms/" + Network.USER_DETAILS.room + ".tscn").instance()
	add_child(_roomInstance)
	print('World Scene - _ready() - ' + Network.USER_DETAILS.room)

func switch_rooms(room: String):
	room = room
	Network.leave_room()
	if _roomInstance != null:
		remove_child(_roomInstance)
	Network.join_room(room)
	_roomInstance = load("res://src/screens/rooms/" + room + ".tscn").instance()
	add_child(_roomInstance)
