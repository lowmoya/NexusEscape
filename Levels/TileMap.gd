extends TileMap
# Called when the node enters the scene tree for the first time.
func _ready():
	if name == "level2":
		flip_horizontally()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func flip_horizontally():
	scale.x *= -1
