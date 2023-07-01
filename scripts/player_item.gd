extends MarginContainer

var _player_id
var _nickname

@onready var nickname_label = $Label

func set_nickname(n):
	nickname_label.text = n
	_nickname = n
	
func set_player_id(id): _player_id = id

func remove(): queue_free()
	

