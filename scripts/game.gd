extends Node2D

var player_scene = preload("res://scenes/player.tscn")

@onready var firebase_manager = $FirebaseManager
@onready var gameplay_node = $Gameplay

@onready var login_node = $CanvasLayer/UI/MarginContainer/Login
@onready var login_button : Button = $CanvasLayer/UI/MarginContainer/Login/Login
@onready var info_label = $CanvasLayer/UI/MarginContainer/Login/Info

signal login_failed(code, message)
signal login_successed

func _ready() -> void:
	
	# Game signals
	self.connect("login_failed", _on_login_failed)
	self.connect("login_successed", _on_login_successed)
	
	# Ui signals	
	login_button.connect("pressed", _on_login_button_pressed)
	
	
func _on_login_button_pressed():
	if !firebase_manager.is_logged_in():
		info_label.text = "Loggining in..."
		login_button.disabled = true
		firebase_manager.login_anonymously()
	else:
		pass
		


func _on_login_failed(code, message):
	info_label.text = "Error: "+str(code)+" ("+str(message)+")"
	login_button.disabled = false
	
func _on_login_successed():
	login_node.hide()
	_spawn_player()
	
	
	
	
	
	
	
	
func _spawn_player(is_self = true):
	var x = randf_range(-400, 400)
	var y = randf_range(-100, 100)
	var player = player_scene.instantiate()
	gameplay_node.add_child(player)
	player.position = Vector2(x, y)
	player.set_is_self(is_self)

