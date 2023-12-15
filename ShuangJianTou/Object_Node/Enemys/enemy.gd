class_name Enemy
#定义所有敌人需要用到的属性、逻辑
extends CharacterBody2D

#敌人左右朝向
enum Direction{
	LEFT = -1,
	RIGHT = +1,
}

@export var faceDirection := Direction.RIGHT:
	set(v):
		faceDirection = v
		if not is_node_ready():
			await ready
		graphics.scale.x = faceDirection
@export var maxSpeed:float = 90
@export var acceleration:float = 2000

var gravity := ProjectSettings.get("physics/2d/default_gravity") as float	#获取系统内部模拟重力

@onready var graphics: Node2D = $Graphics
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var stats: Stats = $Stats


func move(speed:float,delta:float) -> void:
	velocity.x = move_toward(velocity.x,faceDirection * speed,acceleration*delta)
	velocity.y += gravity * delta
	move_and_slide()

func die()->void:
	queue_free()
