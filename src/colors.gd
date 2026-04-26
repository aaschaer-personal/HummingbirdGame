extends Node

var black = Color("000000")
var red = Color("e83b3b")
var pink = Color("eaaded")
var orange = Color("fbb954")
var bright_orange = Color("fb6b1d")
var yellow =  Color("fbff86")
var green = Color("a4e579")
var lightest_green = Color("b7f48e")
var blue = Color("4d9be6")
var purple = Color("a884f3")
var fushia = Color("dd00dd")
var white = Color("ffffff")

var colors_by_species = {
	"sunflower": [red, orange, yellow],
	"jewelweed": [red, orange, yellow, purple],
	"lupine": [red, pink, blue, purple, white],
	"zinnia": [red, fushia, pink, orange, yellow, white],
	"hibiscus": [red, pink, orange, yellow, blue, purple, white],
	"orchid": [red, fushia, pink, orange, yellow, green, blue, purple, white],
}

var color_names = {
	red: "Red",
	pink: "Pink",
	orange: "Orange",
	yellow: "Yellow",
	green: "Green",
	blue: "Blue",
	purple: "Purple",
	fushia: "Fushia",
	white: "White",
}

var rainbow_order = {
	red: 0,
	fushia: 1,
	pink: 2,
	orange: 3,
	yellow: 4,
	green: 5,
	blue: 6,
	purple: 7,
	white: 8,
}

func flower_colors(species):
	return colors_by_species[species]

func color_name(color):
	return color_names[color]

func label_text_from_color_list(colors):
	var ret = ""
	for color in rainbow_order:
		var count = colors.count(color)
		if count == 0:
			pass
		elif count == 1:
			ret += "%s " % color_name(color)
		else:
			ret += "%s (%s) " % [color_name(color), count]
	return ret
