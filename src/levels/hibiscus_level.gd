class_name HibiscusLevel extends Level

var flower_species = "hibiscus"

# flower specific scenes
var cache_top_scene = preload("res://src/cache/level2_cache_top.tscn")
var plant_scene = preload("res://src/flowers/hibiscus/hibiscus_plant.tscn")
var flower_1_scene = preload("res://src/flowers/hibiscus/hibiscus_flower_1.tscn")
var flower_2_scene = preload("res://src/flowers/hibiscus/hibiscus_flower_2.tscn")
var flower_3_scene = preload("res://src/flowers/hibiscus/hibiscus_flower_3.tscn")
var cut_flower_scene = preload("res://src/flowers/hibiscus/cut_hibiscus.tscn")
var flower_icon_texture = preload("res://assets/UI/Icons/hibiscus.png")
var petals_icon_texture = preload("res://assets/UI/Icons/hibiscus_petals.png")

# visitor specific scenes
var visitor_scene = preload("res://src/visitors/yellow_breasted_chat.tscn")
var visitor_icon_texture = preload("res://assets/UI/Icons/yellow_breasted_chat.png")
