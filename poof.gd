extends Sprite2D

const MAX_LIFE = .4
const FRAME_RATE = 5. / MAX_LIFE
var life = MAX_LIFE


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	frame = FRAME_RATE * (MAX_LIFE - life)
	life -= delta
	if life < 0:
		queue_free()
