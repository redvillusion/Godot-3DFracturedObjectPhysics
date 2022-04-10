tool
extends Spatial

export(bool) var create_rigids setget _create_rigids
export(bool) var get_shard_positions setget _get_shard_positions
export(bool) var reset setget _reset
export(bool) var set_mat setget _set_mat

func _set_mat(_value):
	for shard in $ShardsBackup.get_children():
		shard.set_surface_material(0, load("res://Materials/m-pedestal-sphere.tres"))

var shard_positions = {}

func _process(delta):
	if Engine.editor_hint:
		if Input.is_key_pressed(KEY_P):
			print("on")
			PhysicsServer.set_active(true)
		elif Input.is_key_pressed(KEY_N):
			print("off")
			PhysicsServer.set_active(false)
			
func _get_shard_positions(_value):
	shard_positions = {}
	for shard in $Shards.get_children():
		shard_positions[shard] = [shard.translation, shard.rotation_degrees]
	print("Got positions")
		
func _reset(_value):
	for shard in $Shards.get_children():
		shard.translation = shard_positions[shard][0]
		shard.rotation_degrees = shard_positions[shard][1]
	print("Reset Positions")
		

func _create_rigids(_value):
	if Engine.editor_hint:
		for node in $Shards.get_children():
			if node.name.find("cell") != -1:

				var resource_rigidbody = load("RigidBody.tscn")
				
				var s_rigid_body = resource_rigidbody.instance()

				s_rigid_body.translation = node.translation
				s_rigid_body.scale = Vector3(1,1,1)

				$Shards.add_child(s_rigid_body)
				s_rigid_body.set_owner(get_tree().get_edited_scene_root())

				var mesh_node = node

				$Shards.remove_child(node)

				mesh_node.translation = Vector3(0,0,0)
				mesh_node.scale = Vector3(1,1,1)

				s_rigid_body.add_child(mesh_node)

				mesh_node.set_owner(get_tree().get_edited_scene_root())


				# creates a static body with collision shape
				# mesh/static body/collision shape
				mesh_node.create_convex_collision()

				# grabs newly created collision shape
				var collision_node = mesh_node.get_child(0).get_child(0)

				# removes collision shape
				s_rigid_body.get_child(0).get_child(0).remove_child(mesh_node.get_child(0).get_child(0))
				# removes static body
				s_rigid_body.get_child(0).remove_child(mesh_node.get_child(0))

				# re-adds the collision shape, this as a direct child of the rigid body
				s_rigid_body.add_child(collision_node)
				
				collision_node.set_owner(get_tree().get_edited_scene_root())



