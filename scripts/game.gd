extends Node2D

var player_scene = preload("res://scenes/player.tscn")
var player_info = {
	"is_me": false,
	"nickname": "",
	"id": ""
}
var is_logged_in = false
var player_auth_info

@onready var firebase_manager = $FirebaseManager
@onready var gameplay_node = $Gameplay

@onready var login_node = $CanvasLayer/UI/MarginContainer/Login
@onready var nickname_textedit : TextEdit = $CanvasLayer/UI/MarginContainer/Login/NicknameTextEdit
@onready var login_button : Button = $CanvasLayer/UI/MarginContainer/Login/Login
@onready var info_label = $CanvasLayer/UI/MarginContainer/Login/Info

@onready var lobby_and_players_node := $CanvasLayer/UI/MarginContainer/LobbyAndPlayersList

signal login_failed(code, message)
signal login_successed(auth_info)
signal player_added_to_list(player_id)

func _ready() -> void:
	nickname_textedit.text = generate_random_nick()
	
	login_node.show()
	lobby_and_players_node.hide()
	
	# Game signals
	self.connect("login_failed", _on_login_failed)
	self.connect("login_successed", _on_login_successed)
	self.connect("player_added_to_list", _on_player_added_to_list)
	
	# Ui signals	
	login_button.connect("pressed", _on_login_button_pressed)
	
	
func _on_login_button_pressed():
	var nickname = nickname_textedit.text
	if nickname.length() < 3:
		info_label.text = "Min. nickname length is 3."
		return
	
	if !firebase_manager.is_logged_in():
		info_label.text = "Loggining in..."
		login_button.disabled = true
		player_info.is_me = true
		player_info.nickname = nickname
		firebase_manager.login_anonymously()
	else:
		pass
		


func _on_login_failed(code, message):
	info_label.text = "Error: "+str(code)+" ("+str(message)+")"
	login_button.disabled = false
	
func _on_login_successed(auth_info):
	player_auth_info = auth_info
	firebase_manager.add_new_player_to_list(player_info)
	info_label.text = "Adding "+str(player_info.nickname)+" to database..."

func _on_player_added_to_list(player_id):
	player_info.id = player_id
	login_node.hide()
	lobby_and_players_node.show()
	# _spawn_player(player_info)
	
	
func generate_random_nick() -> String:
	var id = randi_range(1000, 9999)
	return "Player#"+str(id)

func _spawn_player(p_info : Dictionary):
	var x = randf_range(-400, 400)
	var y = randf_range(-100, 100)
	var player = player_scene.instantiate()
	gameplay_node.add_child(player)
	player.position = Vector2(x, y)
	player.set_is_me(p_info.is_me)
	player.set_nickname(p_info.nickname)
	player.set_id(p_info.id)

