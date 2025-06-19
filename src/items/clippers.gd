class_name Clippers extends Item

@onready var audio_player = $OptionAwareAudioPlayer

func clip():
	item_sprite.play("clip")
	await item_sprite.animation_finished
	audio_player.play()
