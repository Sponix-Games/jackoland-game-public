extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var destination: Vector2
var direction: Vector2
var velocity = Vector2()
export (int) var speed = 200


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	

func _physics_process(delta):
	
	#modify z to match the y coordinate
	z_index = position.y
	
	#Move to destination
	if $".".position.distance_to(destination) > 20:
		velocity = move_and_slide(velocity)
		
		#Set animation to match direction
		_setAnimationDirection()


#func _input(event):
#	if event is InputEventMouseButton:
#		print("Mouse Click/Unclick at: ", event.position)
#		move($".".position, event.position)
#		Network.move($".".position, event.position)
##	elif event is InputEventMouseMotion:
##		print("Mouse Motion at: ", event.position)


func move(current: Vector2, destination: Vector2):
#	print('move - current: ' + str($Sprite.position.x) + ', ' + str($Sprite.position.y) )
#	print('move - destination: ' + str(destination.x) + ', ' + str(destination.y) )
	self.destination = destination
	
	direction = _getDirection(current, destination)
	velocity = direction * speed
	
func chat(message: String):
	$ChatBubble2.visible = true
	$ChatBubble.text = message
	$ChatTimer.start(6.5)
	
	
func setName(name: String):
	pass
	#$Name.text = name
	
func getName():
	pass
	#return $Name.text
	
func setDestination(destination: Vector2):
	move($".".position, destination)
	
func _getDirection(startDirection: Vector2, endDirection: Vector2):
	var direction = Vector2(endDirection.x-startDirection.x,endDirection.y-startDirection.y).normalized()
	print( direction )
	return direction
	
func _setAnimationDirection():
	var a = stepify(direction.angle(), PI/4) / (PI/4)
	a = wrapi(int(a), 0, 8)
	var anim
	match a:
		0:
			anim = 'right'
		1:
			anim = 'down-right'
		2:
			anim = 'down'
		3:
			anim = 'down-left'
		4:
			anim = 'left'
		5:
			anim = 'up-left'
		6:
			anim = 'up'
		7:
			anim = 'up-right'

	$Sprite.set_animation(anim )

func _on_ChatTimer_timeout():
	$AnimationPlayer.play("ChatBubbleFadeOut")

func start_chat():
	$TypingBubble.visible = true
	$TypingTimer.start(2)


func _on_TypingTimer_timeout():
	$TypingBubble.visible = false


func _on_AnimationPlayer_animation_finished(ChatBubbleFadeOut):
	$ChatBubble.modulate = Color(0, 0, 0)
	$ChatBubble2.modulate = Color(1, 1, 1)
	$ChatBubble.text = ''
	$ChatBubble2.visible = false
