extends Node2D

var player_scene = preload("res://scenes/player.tscn")
var player_item_scene = preload("res://scenes/player_item.tscn")

var player_auth_info

@export var fb_manager : Node2D
@export var fb_rooms_manager : Node2D

@onready var gameplay_node = $Gameplay

@onready var login_node = $CanvasLayer/UI/MarginContainer/Login
@onready var nickname_textedit : TextEdit = $CanvasLayer/UI/MarginContainer/Login/NicknameTextEdit
@onready var login_button : Button = $CanvasLayer/UI/MarginContainer/Login/Login
@onready var info_label = $CanvasLayer/UI/MarginContainer/Login/Info

@onready var matchmaking_node := $CanvasLayer/UI/MarginContainer/Matchmaking

@onready var find_game_button : Button = $CanvasLayer/UI/MarginContainer/Matchmaking/Actions/FindGame
@onready var create_room_button : Button = $CanvasLayer/UI/MarginContainer/Matchmaking/Actions/CreateRoom

@onready var rooms_list_node = $CanvasLayer/UI/MarginContainer/Matchmaking/Rooms
@onready var room_item_scene = preload("res://scenes/room_item.tscn")

@onready var room_node = $CanvasLayer/UI/MarginContainer/Room
@onready var in_room_name_label : Label = $CanvasLayer/UI/MarginContainer/Room/RoomActions/InRoomName
@onready var in_room_nop_label : Label = $CanvasLayer/UI/MarginContainer/Room/RoomActions/InRoomNoP
@onready var in_room_start_button : Button = $CanvasLayer/UI/MarginContainer/Room/RoomActions/InRoomStart
@onready var in_room_leave_button : Button = $CanvasLayer/UI/MarginContainer/Room/RoomActions/InRoomLeave
@onready var in_room_players_node = $CanvasLayer/UI/MarginContainer/Room/InRoomPlayers

@onready var refresh_room_timer : Timer = $RefreshRoom

func _ready() -> void:
	nickname_textedit.text = fb_manager.generate_random_nick()
	
	login_node.show()
	matchmaking_node.hide()
	room_node.hide()
	
	# Firebase signals
	fb_manager.login_successed.connect(_on_login_successed)
	fb_manager.login_failed.connect(_on_login_failed)
	fb_rooms_manager.room_updated.connect(_on_rooms_changed)
	fb_rooms_manager.room_joined.connect(_on_room_joined)
	
	refresh_room_timer.timeout.connect(_refresh_room_timeout)
	
	# Ui signals	
	login_button.connect("pressed", _on_login_button_pressed)
	find_game_button.pressed.connect(_on_find_game_pressed)
	create_room_button.pressed.connect(_on_create_room_pressed)
	
	in_room_start_button.pressed.connect(_start_game)
	in_room_leave_button.pressed.connect(_leave_room)
	
	
	
func _on_login_button_pressed():
	var nickname = nickname_textedit.text
	if nickname.length() < 3:
		info_label.text = "Min. nickname length is 3."
		return
	
	if !fb_manager.is_logged_in():
		info_label.text = "Loggining in..."
		login_button.disabled = true
		fb_manager.login_anonymously(nickname)

func _on_login_failed(code, message):
	info_label.text = "Error: "+str(code)+" ("+str(message)+")"
	login_button.disabled = false
	
func _on_login_successed(auth_info):
	player_auth_info = auth_info
	login_node.hide()
	matchmaking_node.show()
	room_node.hide()
	


func _refresh_room_timeout():
	if fb_manager.local_player_cache.room_id:
		fb_rooms_manager.update_room(fb_manager.local_player_cache.room_id, {})

func _on_find_game_pressed():
	pass

func _on_create_room_pressed():
	if !fb_manager.local_player_cache.room_id:
		fb_rooms_manager.create_room()
		refresh_room_timer.start()

func _on_rooms_changed(data):
	var changed = []
	if fb_manager.local_player_cache.room_id == data.key:
		for player_id in data.data.players:
			var exists = false
			for child in in_room_players_node.get_children():
				if "_player_id" in child:
					if !data.data or !"players" in data.data:
						child.remove()
					else:
						if child._player_id not in data.data.players:
							child.remove()
						else:
							child.set_nickname(data.data.players[player_id].nickname)
							changed.push_front(child)
					
			if !exists:
				var player_item = player_item_scene.instantiate()
				in_room_players_node.add_child(player_item)
				player_item.set_nickname(data.data.players[player_id].nickname)
				player_item.set_player_id(player_id)
				changed.push_front(player_item)
				
		for child in in_room_players_node.get_children():
			if !child in changed and "remove" in child:
				child.remove()
	else:
		if in_room_players_node.get_children().size() > 1:
			for player_item in in_room_players_node.get_children():
				if "_player_id" in player_item: player_item.remove()
			
		
	var room_exists = false
	for child in rooms_list_node.get_children():
		if "_room_id" in child:
			if child._room_id == data.key:
				room_exists = true
				if !data.data or !"players" in data.data:
					child.remove()
				else:
					child.set_number_of_players(data.data.players.size())
			
	if !room_exists:
		if data.data and "players" in data.data:
			var room_item = room_item_scene.instantiate()
			rooms_list_node.add_child(room_item)
			room_item.set_room_id(data.key)
			room_item.set_room_name(data.data.room_name)
			room_item.set_number_of_players(data.data.players.size())
			room_item.join_room.connect(_on_join_room)

func _spawn_player(p_info : Dictionary):
	var x = randf_range(-400, 400)
	var y = randf_range(-100, 100)
	var player = player_scene.instantiate()
	gameplay_node.add_child(player)
	player.position = Vector2(x, y)
	player.set_is_me(p_info.is_me)
	player.set_nickname(p_info.nickname)
	player.set_id(p_info.id)

func _on_room_joined():
	var room = fb_manager.rooms_cache[fb_manager.local_player_cache.room_id]
	in_room_name_label.text = room.room_name
	in_room_nop_label.text = str(room.players.size())+"/4"
	in_room_start_button.disabled = !room.players[fb_manager.local_player_cache.id].is_host
	for player_id in room.players:
		var player_item = player_item_scene.instantiate()
		in_room_players_node.add_child(player_item)
		player_item.set_nickname(fb_manager.local_player_cache.nickname)
		player_item.set_player_id(fb_manager.local_player_cache.id)
		
	
	login_node.hide()
	matchmaking_node.hide()
	room_node.show()

func _start_game():
	pass
	
func _leave_room():
	fb_rooms_manager.leave_room()
	login_node.hide()
	matchmaking_node.show()
	room_node.hide()

func _on_join_room(room_id):
	if fb_manager.local_player_cache.room_id: return
	
	fb_rooms_manager.join_room(room_id)
