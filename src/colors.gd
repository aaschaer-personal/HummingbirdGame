extends Node

var white = Color("ffffff")
var black = Color("000000")
var red = Color("e83b3b")
var pink = Color("eaaded")
var orange = Color("fbb954")
var bright_orange = Color("fb6b1d")
var yellow =  Color("fbff86")
var lightest_green = Color("b7f48e")
var blue = Color("4d9be6")
var purple = Color("a884f3")
var fushia = Color("ff00ff")

var colors_by_species = {
	"sunflower": [red, orange, yellow],
	"jewelweed": [red, orange, yellow, purple],
	"lupine": [red,  pink, blue, purple, white],
	"zinnia": [red, fushia, pink, orange, yellow, white],
}

func flower_colors(species):
	return colors_by_species[species]
