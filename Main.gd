extends Control


var speed:int = 0
var i:int = 0
var spin_finish:bool = true
var total_slices:float = 0.0
var value:float = 0.0
var slice_rotation = null
export var index = 0

var secret = 0
var enable_secret = false


var slice = preload("res://Slice.tscn")
var list_item = preload("res://ListItem.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	yield(get_tree(),"idle_frame")
	OS.window_borderless = false
	OS.window_per_pixel_transparency_enabled = false
	
	spin_finish = true
	add_wheels()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	spin(delta)
#	print(speed)


	if Input.is_key_pressed(KEY_ENTER) and $WindowDialog/Choice.has_focus():
		_on_AddButton_pressed()


func spin(delta):
	$WheelPoint.rotation_degrees += (1 * speed) * delta
	randomize()
	var max_speed = int(rand_range(1000, 3000))
	
	if i >= 0 and not i > max_speed :
		
		if spin_finish == false:
			Global.winner = ""
			$RichTextLabel.bbcode_text = ""
			$RichTextLabel.visible = false
			
			if i == max_speed:
				speed = max_speed
				spin_finish = true
				randomize()
				if enable_secret == true:
					secret = randi() %100 + 1
					print(secret)
				
			else:
				speed = i
				yield(get_tree().create_timer(0.1),"timeout")
				i += 1

	if spin_finish == true and speed > 0:
		if enable_secret == true and secret == 1:
			get_tree().change_scene("res://SECRET.tscn")
		
		else:
			if i > 0 and not i < 0:
				if i <= 5:
					randomize()
					yield(get_tree().create_timer(rand_range(0,10)),"timeout")
					speed = 0
					yield(get_tree(),"idle_frame")
					$RichTextLabel.bbcode_text = "[center]Winner is [wave][rainbow freq=0.3 sat=0.4]%s[/rainbow]" %Global.winner.to_upper()
					$RichTextLabel.visible = true
					$HTTP.search_game()

				else:
					randomize()
					speed = i
					yield(get_tree().create_timer(rand_range(0.1,1)),"timeout")
					i -= 1


func _on_SpinButton_pressed():
	yield(get_tree(),"idle_frame")
	spin_finish = false
	Global.winner = ""
	$RichTextLabel.bbcode_text = ""
	$RichTextLabel.visible = false

	for child in $ScrollContainer/VBoxContainer.get_children():
		$ScrollContainer/VBoxContainer.remove_child(child)
		
	for choice in Global.Wheel_Data.keys():
		var list_item_inst = list_item.instance()
		list_item_inst.get_node("ColorRect").self_modulate = Color(Global.Wheel_Data[choice]["Colour"])
		list_item_inst.get_node("GameName").text = Global.Wheel_Data[choice]["Name"]
		$ScrollContainer/VBoxContainer.add_child(list_item_inst)
	i = 0


func _on_AddSliceButton_pressed():
	$WindowDialog.popup()
	$WindowDialog/Choice.grab_focus()


func _on_AddButton_pressed():
	var choicetext = $WindowDialog/Choice.text
	var slice_inst = slice.instance()
	$WheelPoint.add_child(slice_inst)
	total_slices += 1
	value = 1000/total_slices
	slice_inst.get_node("SliceGraphic").value = float(value)
	slice_inst.name = choicetext
	slice_rotation = float(360)/float(total_slices)
	slice_inst.rect_rotation = slice_rotation
	slice_inst.get_node("SliceLabel").text = choicetext
	Global.Wheel_Data["Choice %s" %total_slices] = {}	
	Global.Wheel_Data["Choice %s" %total_slices]["Name"] = choicetext
	Global.Wheel_Data["Choice %s" %total_slices]["Colour"] = slice_inst.get_node("SliceGraphic").self_modulate.to_html()
	adjust_slices_rotation()
	$WindowDialog.hide()
	$WindowDialog/Choice.text = ""


func adjust_slices_rotation():
	var new_rotation:float = 0.0
	var rotation_amount:float = float(360)/float($WheelPoint.get_children().size())
	for child in $WheelPoint.get_children():
		child.get_node("SliceGraphic").value = float(value)
		child.rect_rotation = float(new_rotation)
		new_rotation += float(rotation_amount)


func _on_Area2D_area_exited(area):
	var last_area = area.get_parent()
	var winner:int = 0
	var choices = $WheelPoint.get_children()
	index = choices.find(last_area)
	winner = index - 1
	Global.winner = choices[winner].name


func _on_SaveWheelButton_pressed():
	var wheel_list = $WheelPoint.get_children()
	var wheel_name = "Wheel %s" %(Global.game_list.keys().size() + 1)
	Global.game_list[wheel_name] = []
	
	for child in $WheelPoint.get_children():
		Global.game_list[wheel_name].append(child.name)
	
	Global.save_data(Global.path, "WheelSaves.json")




func _on_LoadedWheels_item_selected(index):
	Global.Wheel_Data = {}
	
	for child in $WheelPoint.get_children():
		$WheelPoint.remove_child(child)
		
	for child in $ScrollContainer/VBoxContainer.get_children():
		$ScrollContainer/VBoxContainer.remove_child(child)

	
	var wheel_name = $LoadedWheels.get_item_text(index)
	total_slices = 0.0
	
	
	for item in Global.game_list[wheel_name]:
		var choicetext = item
		var slice_inst = slice.instance()
		$WheelPoint.add_child(slice_inst)
		total_slices += 1
		value = 1000/total_slices
		slice_inst.get_node("SliceGraphic").value = float(value)
		slice_inst.name = choicetext
		slice_rotation = float(360)/float(total_slices)
		slice_inst.rect_rotation = slice_rotation
		slice_inst.get_node("SliceLabel").text = choicetext
		Global.Wheel_Data["Choice %s" %total_slices] = {}	
		Global.Wheel_Data["Choice %s" %total_slices]["Name"] = choicetext
		Global.Wheel_Data["Choice %s" %total_slices]["Colour"] = slice_inst.get_node("SliceGraphic").self_modulate.to_html()
		adjust_slices_rotation()


func add_wheels():
	yield(get_tree(),"idle_frame")
	$LoadedWheels.add_item("Select Wheel")
	$LoadedWheels.selected = 0
	$LoadedWheels.set_item_disabled(0, true)
	
	for wheel in Global.game_list.keys():
		$LoadedWheels.add_item(wheel)
	
	for child in $ScrollContainer/VBoxContainer.get_children():
		$ScrollContainer/VBoxContainer.remove_child(child)


func _on_ReloadWheels_pressed():
	$LoadedWheels.clear()
	Global.load_data(Global.path, "WheelSaves.json")
	add_wheels()


func _on_HideNames_pressed():
	for child in $WheelPoint.get_children():
		
		if $WheelPoint.get_node("%s/SliceLabel" %child.name).visible == false:
			$WheelPoint.get_node("%s/SliceLabel" %child.name).visible = true
			
		else:
			$WheelPoint.get_node("%s/SliceLabel" %child.name).visible = false


func _on_GameDetails_meta_clicked(meta):
	OS.shell_open(meta)


func _on_OpenDirButton_pressed():
	OS.shell_open(OS.get_user_data_dir())


func _on_CheckButton_toggled(button_pressed):
	enable_secret = button_pressed





































