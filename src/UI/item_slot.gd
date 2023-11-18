class_name ItemSlot extends TextureRect

var item = null
var item_offset = Vector2(12,8)

func place_item(new_item):
	Helpers.set_parent(new_item, self)
	new_item.position = item_offset
	item = new_item

func remove_item():
	var ret = item
	item = null
	return ret
