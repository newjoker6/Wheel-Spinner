extends TextureProgress


var colour ={
	"R": 0,
	"G": 0,
	"B": 0
}


# Called when the node enters the scene tree for the first time.
func _ready():
	random_num()
	self.self_modulate = Color(colour["R"], colour["G"], colour["B"])



func random_num():
	for i in colour.keys():
		randomize()
		var num = rand_range(0,1)
		colour[i] = num
		print(colour)
