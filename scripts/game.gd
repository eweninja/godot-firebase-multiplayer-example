extends Node2D

var player_scene = preload("res://scenes/player.tscn")
var player_info = {
	"is_me": false,
	"nickname": "",
	"id": ""
}
var is_logged_in = false
var player_auth_info

@export var fb_manager : Node2D
@export var fb_players_manager : Node2D
@export var fb_rooms_manager : Node2D


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

@onready var room_node = $CanvasLayer/UI/MarginContainer/Room
@onready var in_room_name_label : Label = $CanvasLayer/UI/MarginContainer/Room/RoomActions/InRoomName
@onready var in_room_nop_label : Label = $CanvasLayer/UI/MarginContainer/Room/RoomActions/InRoomNoP
@onready var in_room_start_button : Button = $CanvasLayer/UI/MarginContainer/Room/RoomActions/InRoomStart
@onready var in_room_leave_button : Button = $CanvasLayer/UI/MarginContainer/Room/RoomActions/InRoomLeave
@onready var in_room_players_node = $CanvasLayer/UI/MarginContainer/Room/InRoomPlayers


@onready var refresh_player_timer : Timer = $RefreshPlayer
@onready var refresh_room_timer = $RefreshRoom


var online_players = {}

func _ready() -> void:
	nickname_textedit.text = generate_random_nick()
	
	login_node.show()
	lobby_and_players_node.hide()
	room_node.hide()
	
	# Firebase signals
	fb_manager.login_successed.connect(_on_login_successed)
	fb_manager.login_failed.connect(_on_login_failed)
	fb_players_manager.player_added_to_list.connect(_on_player_added_to_list)
	fb_players_manager.players_online_changed.connect(_on_players_online_changed)
	fb_rooms_manager.room_updated.connect(_on_rooms_changed)
	fb_rooms_manager.room_joined.connect(_on_room_joined)
	
	refresh_player_timer.timeout.connect(_refresh_player_timeout)
	refresh_room_timer.timeout.connect(_refresh_room_timeout)
	
	# Ui signals	
	login_button.connect("pressed", _on_login_button_pressed)
	find_game_button.pressed.connect(_on_find_game_pressed)
	create_room_button.pressed.connect(_on_create_room_pressed)
	
	
	
func _on_login_button_pressed():
	var nickname = nickname_textedit.text
	if nickname.length() < 3:
		info_label.text = "Min. nickname length is 3."
		return
	
	if !fb_manager.is_logged_in():
		info_label.text = "Loggining in..."
		login_button.disabled = true
		player_info.is_me = true
		player_info.nickname = nickname
		fb_manager.login_anonymously()
	else:
		pass
		


func _on_login_failed(code, message):
	info_label.text = "Error: "+str(code)+" ("+str(message)+")"
	login_button.disabled = false
	
func _on_login_successed(auth_info):
	player_auth_info = auth_info
	fb_players_manager.add_new_player_to_list(player_info)
	info_label.text = "Adding "+str(player_info.nickname)+" to database..."

func _on_player_added_to_list(player_id):
	player_info.id = player_id
	login_node.hide()
	lobby_and_players_node.show()
	room_node.hide()
	# _spawn_player(player_info)
	
	
func generate_random_nick() -> String:
	var id = randi_range(1000, 9999)
	return "Player#"+str(id)
	
func generate_random_room_name() -> String:
	var id = randi_range(10000, 99999)
	return "Room#"+str(id)

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
	fb_manager.update_player(player_info.id, {})

func _refresh_room_timeout():
	if fb_manager.local_player_room_id != "":
		fb_manager.update_room(fb_manager.local_player_room_id, {})

func _on_find_game_pressed():
	pass

func _on_create_room_pressed():
	if fb_manager.local_player_room_id == "":
		fb_rooms_manager.create_room({
			"room_name": generate_random_room_name()
		}, player_info)
		refresh_room_timer.start()

func _on_rooms_changed(data):
	if fb_manager.local_player_room_id == data.key:
		if data.data: return
		if !"players" in data.data: return
		
		var changed = []
		for player_id in data.data.players:
			var exists = false
			for child in in_room_players_node.children():
				if "_player_id" in child:
					child.set_nickname(data.data.players[player_id])
					changed.push()
					
			if !exists:
				var player_item = player_item_scene.instantiate()
				in_room_players_node.add_child(player_item)
				player_item.set_nickname(data.data.players[player_id].nickname)
				player_item.set_player_id(player_id)
				changed.push(player_item)
				
		for child in in_room_players_node.children():
			if !child in changed:
				child.remove()
							
	else:
		var room_exists = false
		for child in rooms_list_node.get_children():
			if "_room_id" in child:
				if child._room_id == data.key:
					room_exists = true
					if !data.data:
						child.remove()
					else:
						if "players" in data.data:
							child.set_number_of_players(data.data.players.size())
						else:
							child.remove()
				
		if !room_exists:
			var room_item = room_item_scene.instantiate()
			rooms_list_node.add_child(room_item)
			room_item.set_room_id(data.key)
			room_item.set_room_name(data.data.room_name)
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

func _on_room_joined(data):
	
	in_room_name_label.text = data.data.room_name
	in_room_nop_label.text = str(data.data.players.size())+"/4"
	in_room_start_button.disabled = !data.data.players[fb_manager.local_player_id].is_host
	for player_id in data.data.players:
		var player_item = player_item_scene.instantiate()
		in_room_players_node.add_child(player_item)
		player_item.set_nickname(data.data.players[player_id].nickname)
		player_item.set_player_id(player_id)
		
	
	login_node.hide()
	lobby_and_players_node.hide()
	room_node.show()
