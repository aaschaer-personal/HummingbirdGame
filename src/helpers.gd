extends Node

func set_parent(node, new_parent):
	var old_parent = node.get_parent()
	if old_parent:
		old_parent.remove_child(node)
	new_parent.add_child(node)

func get_only_child(node):
	var children = node.get_children()
	if children.size() == 1:
		return children[0]
	else:
		return null

func point_in_area(point: Vector2, area: Area2D):
		var querry_point = PhysicsPointQueryParameters2D.new()
		querry_point.position = point
		querry_point.collide_with_bodies = false
		querry_point.collide_with_areas = true
		var overlapping_areas = (
			area.get_world_2d().direct_space_state.intersect_point(querry_point)
		)
		for overlaping_area in overlapping_areas:
			if overlaping_area.collider == area:
				return true
		
		return false
