extends Sprite2D

@export var object_height = 0
@export var height_off_ground = 0
var shadow_sprite

func _ready():
	shadow_sprite = Sprite2D.new()
	add_child(shadow_sprite)
	shadow_sprite.texture = texture
	shadow_sprite.scale = Vector2(1, .5)
	shadow_sprite.modulate = Colors.black
	shadow_sprite.modulate.a = .2
	shadow_sprite.z_index -= 1

func _process(_delta):
	shadow_sprite.position.y = (object_height * 3.0/4.0) + height_off_ground
	shadow_sprite.flip_v = !flip_v

@warning_ignore("native_method_override")
func set_flip_v(val:bool):
	flip_v = val
	shadow_sprite = !val
	
@warning_ignore("native_method_override")
func set_flip_h(val:bool):
	flip_h = val
	shadow_sprite.flip_h = val
