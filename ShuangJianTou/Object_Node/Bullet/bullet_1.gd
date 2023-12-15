extends Area2D

@onready var sprite_2d: Sprite2D = $Sprite2D

var speed = 200
var moveDirection = 1

func _physics_process(delta: float) -> void:
	position.x += moveDirection * speed * delta



func _on_area_entered(area: Area2D) -> void:
	pass # Replace with function body.
