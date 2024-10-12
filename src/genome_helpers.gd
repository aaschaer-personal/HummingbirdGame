# autoloaded as GenomeHelpers
extends Node

func sunflower_flower_color(color):
	if color == 2:
		return Colors.red
	elif color == 1:
		return Colors.orange
	elif color == 0:
		return Colors.yellow
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
