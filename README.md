# godot-firebase-multiplayer-example

**Work in progress**.

Example project in Godot 4.1 using [GodotFirebase](https://github.com/GodotNuts/GodotFirebase).
Firebase Realtime Database shared multiplayer with authority for own player.

## Reason

- I'm creating this project for reference, as a basic example of creating multiplayer in Godot 4 using Firebase (mostly Firebase Realtime Database).
- Learning. 😊



## About project

- Anonymous login.
- Setting nickname.
- Creating lobby room.
- Joining lobby room.
- Matchmaking:
	- Search for open rooms:
		- If open room exists, join it.
		- Else create new open room and wait for other players.
- In lobby room:
	- Starting game.
	- Leaving room.
	- Text chat (optionally).
- Gameplay:
	- Spawning players:
		- Self.
		- Remote.
	- Sending player position.
	- Receiving remote players position.
	- Broadcasting player actions.
	- Host migration.
- Game end:
	- Showing results.
	- Going back to lobby.

## Database workflow

**How are players added to db?**
Players are added after loggining in. Every player is updating themself every 120 s.

**How are players removed from db?**
Player `updated_time` property is compared with actual time. If diff is more than 120 s - player is removed.

**How are rooms added to db?**
Rooms are added then logged in player perform `Create Room` action. Room has property `marked_to_remove = false`.

**How are rooms removed from db?**
Rooms are first marked as `marked_to_remove = true` and then removed. They are makred then players number is 0 (`roomId.players == {}`).

**How are sessions added to db?**
-

**How are sessions removed from db?**

To include everything in one project, every game instance are making cleanups for `players`, `rooms` and `sessions`.


## Todo

- [x] Add login (anonymous).
- [x] Add simple player scene.
- [x] Add player nicknames.
- [ ] Lobby rooms.
- [ ] Matchmaking.
- [ ] Simple "gameplay".
- [ ] Game end.
- [ ] Change naming to more reasonable, like room vs lobbby.
- [ ] Refactor code.


## Database structure

```json
{
  "players": {
	"$playerId": {
	  "nickname": "Player#1000",
	  "updated_time": 0
	}
  },
  "rooms": {
	"$roomId": {
	  "marked_to_remove": false,
	  "players": {
		"$playerId": {
		  "isHost": true
		}
	  }
	}
  },
  "sessions": {
	"$sessionId": {
	  "roomId": "abc123",
	  "status": "active",
	  "startTime": 1656789123456,
	  "stats": {
		"$playerId": {}
	   }
	}
  }
}
```

- Players | Keeps track of online players.
- Rooms | Keeps track of lobby rooms.
- Sessions | Keeps track of ongoing games.

