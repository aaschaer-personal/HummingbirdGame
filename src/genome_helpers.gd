# autoloaded as GenomeHelpers
extends Node

func code_from_gene_dict(gene_dict):
	var species = gene_dict["species"]
	if species == "sunflower":
		return sunflower_code(gene_dict["color"])
	elif species == "jewelweed":
		return jewelweed_code(gene_dict["color"])
	elif species == "lupine":
		return lupine_code(gene_dict["red"], gene_dict["blue"])
	elif species == "zinnia":
		return zinnia_code(gene_dict["color"])
	else:
		assert(false)

func color_from_gene_dict(gene_dict):
	var species = gene_dict["species"]
	if species == "sunflower":
		return sunflower_color(gene_dict["color"])
	elif species == "jewelweed":
		return jewelweed_color(gene_dict["color"])
	elif species == "lupine":
		return lupine_color(gene_dict["red"], gene_dict["blue"])
	elif species == "zinnia":
		return zinnia_color(gene_dict["color"])
	else:
		assert(false)

var sunflower_code_color_map = {
	"RR": Colors.red,
	"RY": Colors.orange,
	"YY": Colors.yellow,
}

func sunflower_code(color):
	if color[0] == "R":
		return color[0] + color[1]
	else:
		return color[1] + color[0]

func sunflower_color(color):
	return sunflower_code_color_map[sunflower_code(color)]

var jewelweed_code_color_map = {
	"RR": Colors.red,
	"RP": Colors.red,
	"RY": Colors.orange,
	"PP": Colors.purple,
	"PY": Colors.purple,
	"YY": Colors.yellow,
}

func jewelweed_code(color):
	var order = {
		"R": 0,
		"P": 1,
		"Y": 2,
	}
	if order[color[0]] < order[color[1]]:
		return color[0] + color[1]
	else:
		return color[1] + color[0]
		
func jewelweed_color(color):
	return jewelweed_code_color_map[jewelweed_code(color)]

var lupine_code_color_map = {
	"RRBB": Colors.purple,
	"RRBb": Colors.purple,
	"RRbb": Colors.red,
	"RrBB": Colors.purple,
	"RrBb": Colors.purple,
	"Rrbb": Colors.pink,
	"rrBB": Colors.blue,
	"rrBb": Colors.blue,
	"rrbb": Colors.white,
}

func lupine_code(red, blue):
	var code = ""
	if red[0] == "R":
		code += red[0] + red[1]
	else:
		code += red[1] + red[0]
	if blue[0] == "B":
		code += blue[0] + blue[1]
	else:
		code += blue[1] + blue[0]
	return code

func lupine_color(red, blue):
	return lupine_code_color_map[lupine_code(red, blue)]

var zinnia_code_color_map = {
	"RR": Colors.red,
	"RF": Colors.red,
	"RY": Colors.orange,
	"RW": Colors.pink,
	"FF": Colors.fushia,
	"FY": Colors.fushia,
	"FW": Colors.fushia,
	"YY": Colors.yellow,
	"YW": Colors.yellow,
	"WW": Colors.white,
}

func zinnia_code(color):
	var order = {
		"R": 0,
		"F": 1,
		"Y": 2,
		"W": 3,
	}
	if order[color[0]] < order[color[1]]:
		return color[0] + color[1]
	else:
		return color[1] + color[0]

func zinnia_color(color):
	return zinnia_code_color_map[zinnia_code(color)]
