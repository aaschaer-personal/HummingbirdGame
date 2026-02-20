class_name OrchidLevel extends Level

var flower_species = "orchid"

# flower specific scenes
var cache_top_scene = preload("res://src/cache/level2_cache_top.tscn")
var plant_scene = preload("res://src/flowers/orchid/orchid_plant.tscn")
var flower_1_scene = preload("res://src/flowers/orchid/orchid_flower_1.tscn")
var flower_2_scene = preload("res://src/flowers/orchid/orchid_flower_2.tscn")
var flower_3_scene = preload("res://src/flowers/orchid/orchid_flower_3.tscn")
var cut_flower_scene = preload("res://src/flowers/orchid/cut_orchid.tscn")
var flower_icon_texture = preload("res://assets/UI/Icons/orchid.png")
var petals_icon_texture = preload("res://assets/UI/Icons/orchid_petals.png")

# visitor specific scenes
var visitor_scene = preload("res://src/visitors/american_redstart.tscn")
var visitor_icon_texture = preload("res://assets/UI/Icons/american_redstart.png")
