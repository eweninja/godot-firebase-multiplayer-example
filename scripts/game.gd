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

@onready var find_game_button : Button = $CanvasLayer/UI/MarginContainer/LobbyAndPlayersList/Actions/FindGame
@onready var create_room_button : Button = $CanvasLayer/UI/MarginContainer/LobbyAndPlayersList/Actions/CreateRoom

@onready var players_list_node = $CanvasLayer/UI/MarginContainer/LobbyAndPlayersList/PlayersList
@onready var player_item_scene = preload("res://scenes/player_item.tscn")

@onready var rooms_list_node = $CanvasLayer/UI/MarginContainer/LobbyAndPlayersList/Lobbies
@onready var room_item_scene = preload("res://scenes/room_item.tscn")



@onready var refresh_player_timer : Timer = $RefreshPlayer




signal login_failed(code, message)
signal login_successed(auth_info)
signal player_added_to_list(player_id)
signal players_online_changed(data)
signal player_online_removed(data)
signal rooms_changed(data)
signal room_removed(data)
signal room_joined(data)

var online_players = {}

func _ready() -> void:
	nickname_textedit.text = generate_random_nick()
	
	login_node.show()
	lobby_and_players_node.hide()
	
	# Game signals
	self.connect("login_failed", _on_login_failed)
	self.connect("login_successed", _on_login_successed)
	self.connect("player_added_to_list", _on_player_added_to_list)
	self.players_online_changed.connect(_on_players_online_changed)
	self.rooms_changed.connect(_on_rooms_changed)
	# self.player_online_removed.connect(_on_player_removed)
	
	refresh_player_timer.timeout.connect(_refresh_player_timeout)
	
	# Ui signals	
	login_button.connect("pressed", _on_login_button_pressed)
	find_game_button.pressed.connect(_on_find_game_pressed)
	create_room_button.pressed.connect(_on_create_room_pressed)
	
	
	
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

func _on_players_online_changed(data):
	online_players[data.key] = data.data
	
	var user_exists = false
	for child in players_list_node.get_children():
		if "_player_id" in child:
			if child._player_id == data.key:
				user_exists = true
				if data.data == null:
					child.remove()
				else:
					child.set_nickname(data.data.nickname)
				
	if !user_exists:
		var player_item = player_item_scene.instantiate()
		players_list_node.add_child(player_item)
		player_item.set_player_id(data.key)
		player_item.set_nickname(data.data.nickname)

func _refresh_player_timeout():
	firebase_manager.update_player(player_info.id, {})

func _on_find_game_pressed():
	pass

func _on_create_room_pressed():
	firebase_manager.create_room({})

func _on_rooms_changed(data):
	var room_exists = false
	for child in rooms_list_node.get_children():
		if "_room_id" in child:
			if child._room_id == data.key:
				room_exists = true
				if data.data == null:
					child.remove()
				else:
					child.set_number_of_players(data.data.players.size())
				
	if !room_exists:
		var room_item = room_item_scene.instantiate()
		rooms_list_node.add_child(room_item)
		room_item.set_room_id(data.key)
		room_item.set_number_of_players(data.data.players.size())




func _spawn_player(p_info : Dictionary):
	var x = randf_range(-400, 400)
	var y = randf_range(-100, 100)
	var player = player_scene.instantiate()
	gameplay_node.add_child(player)
	player.position = Vector2(x, y)
	player.set_is_me(p_info.is_me)
	player.set_nickname(p_info.nickname)
	player.set_id(p_info.id)


