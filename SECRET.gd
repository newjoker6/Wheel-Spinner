extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	yield(get_tree(),"idle_frame")
	OS.window_borderless = false
	OS.window_per_pixel_transparency_enabled = false



func _on_BackButton_pressed():
	get_tree().change_scene("res://Main.tscn")
