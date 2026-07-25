extends Node

func sort_by_visual_order(a: Node2D, b: Node2D):
	if a.z_index != b.z_index:
		return a.z_index < b.z_index
	
	var aidx = a.get_index()
	var bidx = b.get_index()

	return aidx < bidx

func format_time(seconds: int):
	var m = seconds / 60
	var s = seconds % 60

	return "%02d:%02d" % [m, s]

func wait(time: float):
	return get_tree().create_timer(time).timeout