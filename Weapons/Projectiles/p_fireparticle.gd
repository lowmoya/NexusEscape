extends Area2D

@export var n_rect: ColorRect
@export var n_collider: CollisionShape2D
@export var n_audioplayer: AudioStreamPlayer2D

var color_falloff: float
var displacement_radius: float
var displacement_direction: Vector2
var initial_time: int
var hit: bool = false
var last_acted: int = 0

func setup(frame, max_radius):
	n_rect.color.g = randf_range(.4, .7)
	color_falloff = n_rect.color.g / float(frame - Time.get_ticks_msec()) * 1000.
	displacement_radius = max_radius * randf_range(.1, 1.)
	displacement_direction = Vector2(1. if randi_range(0, 1) == 1 else -1., \
			1. if randi_range(0, 1) == 1 else -1.)
	initial_time = Time.get_ticks_msec()
	n_audioplayer.pitch_scale = randf_range(.9, 1.1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var current_time = Time.get_ticks_msec()
	n_rect.position = displacement_radius * Vector2( \
			displacement_direction[0] * cos((current_time - initial_time) / 100.), \
			displacement_direction[1] * sin((current_time - initial_time) / 100.))
	n_rect.color.g -= color_falloff * delta


func _on_body_entered(body):
	if body is Entity:
		var current_time = Time.get_ticks_msec()
		if current_time > last_acted:
			body.damage(.02)
			body.fire_stacks += .08
			last_acted = current_time + .1
		return
	elif not body is TileMap:
		body.try(3)
	hit = true
	visible = false
	n_collider.set_deferred("disabled", true)
