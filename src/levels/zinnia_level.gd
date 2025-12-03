class_name ZinniaLevel extends Level

var flower_species = "zinnia"

# flower specific scenes
var cache_top_scene = preload("res://src/cache/level4_cache_top.tscn")
var plant_scene = preload("res://src/flowers/zinnia/zinnia_plant.tscn")
var flower_1_scene = preload("res://src/flowers/zinnia/zinnia_flower_1.tscn")
var flower_2_scene = preload("res://src/flowers/zinnia/zinnia_flower_2.tscn")
var flower_3_scene = preload("res://src/flowers/zinnia/zinnia_flower_3.tscn")
var cut_flower_scene = preload("res://src/flowers/zinnia/cut_zinnia.tscn")
var flower_icon_texture = preload("res://assets/UI/Icons/zinnia.png")
var petals_icon_texture = preload("res://assets/UI/Icons/zinnia_petals.png")

# visitor specific scenes
var visitor_scene = preload("res://src/visitors/blue_grosbeak.tscn")
var visitor_icon_texture = preload("res://assets/UI/Icons/blue_grosbeak.png")
