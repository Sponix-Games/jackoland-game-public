## 
## client.gd
##
## This file is part of: PlayerSpace
##
## Copyright (c) 2022 Emmanuel Barroga
##
## THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
## EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF    
## MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
## IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY  
## CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,  
## TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE     
## SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                
##

extends Node

# The URL we will connect to
#export var websocket_url = "ws://localhost:8080"
export var websocket_url = "wss://jackoland-server.herokuapp.com/:43902"

# Our WebSocketClient instance
var _client = WebSocketClient.new()


var RDB	#realtime database
var DB	# firestore database
var USERNAME : String
var USER_DETAILS = { 'username': 'player', 'room': 'town'}
var MESSAGES = null
var PLAYERS = {}

var WORLD = null



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass



func _ready():
	pass


func signup(email, password):
	pass


func login():
# Connect base signals to get notified of connection open, close, and errors.
	_client.connect("connection_closed", self, "_closed")
	_client.connect("connection_error", self, "_closed")
	_client.connect("connection_established", self, "_connected")
	# This signal is emitted when not using the Multiplayer API every time
	# a full packet is received.
	# Alternatively, you could check get_peer(1).get_available_packets() in a loop.
	_client.connect("data_received", self, "_on_data")

	# Initiate connection to the given URL.
	var err = _client.connect_to_url(websocket_url, ['websocket'], false, ['Authorization: tt'])
	if err != OK:
		print("Unable to connect")
		set_process(false)
		
		

func _closed(was_clean = false):
	# was_clean will tell you if the disconnection was correctly notified
	# by the remote peer before closing the socket.
	print("Closed, clean: ", was_clean)
	set_process(false)
	get_tree().change_scene("res://src/screens/login/Login.tscn")

func _connected(proto = ""):
	# This is called on connection, "proto" will be the selected WebSocket
	# sub-protocol (which is optional)
	print("Connected with protocol: ", proto)
	# You MUST always use get_peer(1).put_packet to send data to server,
	# and not put_packet directly when not using the MultiplayerAPI.
	
	#var packet = {'id': 0x02, 'chat': 'hello world'}
	#_client.get_peer(1).put_packet(JSON.print(packet).to_utf8())

func _on_data():
	# Print the received packet, you MUST always use get_peer(1).get_packet
	# to receive data from server, and not get_packet directly when not
	# using the MultiplayerAPI.
	var d = JSON.parse(_client.get_peer(1).get_packet().get_string_from_utf8()).result
	print("Got data from server: ", d)

	if d.id == 2:
		print("PID: " + d.pid + " says: " + d.chat)
		PLAYERS[d.pid].chat(d.chat)
		get_node("../World/Chat/Chatbox").addMessage(d.pid, d.chat, 1)
	
	elif d.id == 3:
		print("PID: " + d.pid + " joined.")
		
		var instance = load("res://src/actors/RemotePlayer.tscn").instance()
		PLAYERS[d.pid] = instance

		##instance.get_node("BodyPivot").get_node("Body").scale = Vector2(2,2)
		#instance.get_node("StateMachine").is_remote = true
		get_parent().get_node('World').add_child(instance)
		
	elif d.id == 4:
		print("PID: " + d.pid + " left.")
		PLAYERS[d.pid].queue_free()
		PLAYERS.erase(d.pid)

	elif d.id == 5:
		print("PID: " + d.pid + " moved.")
		PLAYERS[d.pid].setDestination(Vector2(d.dx, d.dy))
	
	elif d.id == 6:
		print("PID " + d.pid + " is thinking.")
		PLAYERS[d.pid].start_chat()

func _process(delta):
	# Call this in _process or _physics_process. Data transfer, and signals
	# emission will only happen when calling this function.
	_client.poll()


func join_room(name: String):
	print('JOINING ROOM - "' + name + '"...')
	

func leave_room():
	print('LEAVE ROOM - "' + name + '"...')

	
	for p in PLAYERS:
		if PLAYERS[p].getName() != USER_DETAILS.username:
			PLAYERS[p].queue_free()
			PLAYERS.erase(p)

func chat(msg: String):
	print('SENDING CHAT - ' + msg)
	var packet = {'id': 0x02, 'chat': msg}
	_client.get_peer(1).put_packet(JSON.print(packet).to_utf8())


func move(current, destination):
	var packet = {'id': 0x05, 'x': current.x, 'y': current.y, 'dx': destination.x, 'dy': destination.y}
	_client.get_peer(1).put_packet(JSON.print(packet).to_utf8())
	#var db = Firebase.Database.get_database_reference('/users/'+ USER_DETAILS.room)
	#db.update(USER_DETAILS.username, {'x': destination.x, 'y': destination.y})

func is_thinking():
	print("THINKING")
	var packet = {"id": 0x06}
	_client.get_peer(1).put_packet(JSON.print(packet).to_utf8())

############# SIGNALS#######################
func _on_signup_succeeded(auth_info : Dictionary):
	
	print('SIGN UP SUCCESSFUL! - ' + JSON.print(auth_info)) 

func _on_login_succeeded(auth_info : Dictionary):
	
	join_room(USER_DETAILS.room)
	
	print('LOGIN SUCCESSFUL!')
	
	get_tree().change_scene("res://src/screens/WorldScene.tscn")
	
func _on_login_failed(code, message: String):
	print('LOGIN FAILED! - ' + JSON.print(message))



func _on_new_data_update(data):
	print('NEW DATA')
	print(JSON.print(data))
	
	var splitKey = data.key.split('/')
	for i in splitKey:
		print('split key: ' + i)

	if splitKey[0] != null && splitKey.size() == 1:
			#check if a remote actor exists with tthat name if not create it
			#move the actor
			var instance = null
			if USER_DETAILS.username != splitKey[0]: #checking if we're making remote player
				if PLAYERS.has(splitKey[0]) == false:
					print('New Remote Player - ' + splitKey[0])
					instance = load("res://src/actors/RemotePlayer.tscn").instance()
					PLAYERS[splitKey[0]] = instance
					instance.set_name(splitKey[0])
					instance.setName(splitKey[0])
					get_parent().get_node('World').add_child(instance)
					
			elif USER_DETAILS.username == splitKey[0]: #checking if we're making local player
				if PLAYERS.has(splitKey[0]) == false:
					print('New Local Player - ' + splitKey[0])
					instance = load("res://src/actors/Player.tscn").instance()
					PLAYERS[splitKey[0]] = instance
					instance.set_name(splitKey[0])
					instance.setName(splitKey[0])
					get_parent().get_node('World').add_child(instance)
					
			
			if data.data != null:
				if data.data.has('x'):
					PLAYERS[splitKey[0]].position.x = data.data['x']
				if data.data.has('y'):
					PLAYERS[splitKey[0]].position.y = data.data['y']
					
			if data.data == null:
				if PLAYERS.has(splitKey[0]):
					PLAYERS[splitKey[0]].queue_free()
					PLAYERS.erase(splitKey[0])


	
	
	
	
