extends Node2D

@onready var firebase_manager = $FirebaseManager

@onready var login_button : Button = $CanvasLayer/UI/MainMenu/VBoxContainer/Login
@onready var info_label = $CanvasLayer/UI/MainMenu/VBoxContainer/Info

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
	pass
