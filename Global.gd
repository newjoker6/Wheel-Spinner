extends Node



var Wheel_Data= {}
var winner:String
var path = "user://"
var file = File.new()
var game_list = {}

func _ready():
	OS.set_window_title("Spin The Wheel - TehJackson Entertainment")
	load_data(Global.path, "WheelSaves.json")

func save_data(savePath, file_name):
	file.open(savePath + file_name, file.WRITE)
	file.store_line(to_json(game_list))
	file.close()
	print(OS.get_user_data_dir())


func load_data(savePath, file_name):
	if file.file_exists(savePath + file_name):
		file.open(savePath + file_name, file.READ)
		var tmp_data = file.get_as_text()
		var parsed_data = {}
		parsed_data = parse_json(tmp_data)
		
		game_list = parsed_data
		prints("The loaded game list: ", game_list)
