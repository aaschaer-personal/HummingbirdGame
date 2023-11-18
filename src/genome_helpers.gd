# autoloaded as GenomeHelpers
extends Node

func sunflower_flower_color(yellow):
	if yellow == 2:
		return Colors.orange
	elif yellow == 1:
		return Colors.yellow
	elif yellow == 0:
		return Colors.white
	else:
		assert(false)

func lupine_flower_color(red, blue):
	if red == 2:
		if blue == 0:
			return Color.DARK_RED
		else:
			return Color.BLUE_VIOLET
	if red == 1:
		if blue == 0:
			return Color.LIGHT_PINK
		else:
			return Color.BLUE_VIOLET
	if red == 0:
		if blue == 0:
			return Color.WHITE
		else:
			return Color.MEDIUM_BLUE
