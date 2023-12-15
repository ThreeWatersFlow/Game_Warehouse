extends Node2D

@onready var tile_map: TileMap = $TileMap
@onready var camera_2d: Camera2D = $player/Camera2D

func _ready() -> void:
	var used := tile_map.get_used_rect()
	var tile_size := tile_map.tile_set.tile_size




func _on_player_shoot(Bullet, shootLocation,faceDirection):
	var spawned_bullet = Bullet.instantiate()
	add_child(spawned_bullet)
	
	spawned_bullet.position = shootLocation
	spawned_bullet.moveDirection = faceDirection
	if spawned_bullet.moveDirection == 1:
		spawned_bullet.sprite_2d.flip_h = true

