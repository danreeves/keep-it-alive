tool # Needed so it runs in editor
extends EditorScenePostImport

# This sample changes all node names

# Called right after the scene is imported and gets the root node
func post_import(scene):
	iterate(scene)
	return scene # Remember to return the imported scene

func iterate(node: Node):
	if node != null:
		if node is MeshInstance && "-col" in node.get_parent().name:
			print(node.name + " " + node.get_parent().name)
			var collider = node.create_trimesh_collision()
			print(collider)
			if collider != null:
				node.add_child(collider)

		for child in node.get_children():
			if child != null:
				iterate(child)
