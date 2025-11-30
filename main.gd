extends Node

const SAVE_INTERVAL := 2.0

var save_timer := 0.0
var dirty := false
var buffer := StreamPeerBuffer.new()

var game_state := {
	"time": 0,
}

func _process(delta):
	save_timer += delta

	if dirty and save_timer >= SAVE_INTERVAL:
		save_timer = 0.0
		flush_to_disk()
		dirty = false


func update_state(new_time: int):
	# Update game state
	game_state.time = new_time

	# Clear and update RAM buffer
	buffer.clear()
	buffer.put_string(JSON.stringify(game_state))

	dirty = true


func flush_to_disk():
	var save_path := "user://save.dat"
	var file := FileAccess.open(save_path, FileAccess.WRITE)

	if file:
		file.store_buffer(buffer.data_array)
		file.close()
		print("Saved to disk:", save_path)
	else:
		push_error("Could not open save file!")


func load_from_disk():
	var save_path := "user://save.dat"

	if not FileAccess.file_exists(save_path):
		print("No save file to load.")
		return

	var file := FileAccess.open(save_path, FileAccess.READ)
	var data := file.get_buffer(file.get_length())
	file.close()

	var buf := StreamPeerBuffer.new()
	buf.data_array = data

	var text := buf.get_string()
	game_state = JSON.parse_string(text)

	print("Loaded:", game_state)
