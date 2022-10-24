extends TextureButton


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_Login_mouse_entered():
	self.set_scale(Vector2(1.1, 1.1))

func _on_Login_mouse_exited():
	self.set_scale(Vector2(1, 1))

func _on_Login_pressed():
	get_tree().change_scene("res://src/screens/WorldScene.tscn")
	Network.login()
