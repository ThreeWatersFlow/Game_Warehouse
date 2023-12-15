extends CharacterBody2D
#人物的基本状态
enum State{
	IDLE,
	RUNNING,
	JUMP,
	FALL,
	LANDING,#着陆
	ATTACK,
}
#人物面朝方向
enum Direction{
	LEFT = -1,
	RIGHT = +1,
}

#位于地面上的状态
const GROUND_STATES = [State.IDLE,State.RUNNING,State.LANDING,State.ATTACK]

@onready var sprite_2d = $Sprite2D
@onready var animation_player = $AnimationPlayer
@onready var coyote_timer: Timer = $CoyoteTimer		#郊狼时间
@onready var jump_request_timer: Timer = $JumpRequestTimer	#提前跳跃按键
@onready var marker_2d: Marker2D = $Marker2D

@export var faceDirection = Direction.LEFT	#人物面朝方向
@export var isShoot = false	#是否射击

var moveSpeed = 250	#移动速度
var acceleration = moveSpeed / 0.2#水平移动加速度
var jumpVelocity = -400	#跳跃力
var shouldJump = false	#是否应当进入跳跃状态
var gravity := ProjectSettings.get("physics/2d/default_gravity") as float	#获取系统内部模拟重力

#射击
signal shoot(bullet,shootLocation,moveDirection)#(子弹对象，发射位置，移动方向)
var Bullet = preload("res://Bullet/bullet_1.tscn")


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		jump_request_timer.start()
	if event.is_action_released("jump"):
		jump_request_timer.stop()
		if  velocity.y < jumpVelocity / 2:
			velocity.y = jumpVelocity / 2
	#if event.is_action_pressed("attack"):#射击按键
		#shoot.emit(Bullet,marker_2d.global_position,faceDirection)
		
func tick_physics(state:State,delta:float) -> void:
	match state:
		State.IDLE:
			move(delta)
		State.RUNNING:
			move(delta)
		State.JUMP:
			move(delta)
		State.FALL:
			move(delta)
		State.LANDING:
			pass
			#move(delta)	
		State.ATTACK:
			if isShoot:
				shoot.emit(Bullet,marker_2d.global_position,faceDirection)
				isShoot = false
			pass
	
func move(delta:float) -> void:
	var direction := Input.get_axis("move_left","move_right")
	velocity.x = move_toward(velocity.x,direction * moveSpeed,acceleration*delta)
	velocity.y += gravity * delta

	if not is_zero_approx(direction):
		sprite_2d.flip_h = direction > 0
		if(sprite_2d.flip_h == true):
			faceDirection = Direction.RIGHT
		else:
			faceDirection = Direction.LEFT
	move_and_slide()


func get_next_state(state:State)->State:
	shouldJump = (is_on_floor() or coyote_timer.time_left > 0) and jump_request_timer.time_left > 0
	if shouldJump:
		return State.JUMP
		
	var direction := Input.get_axis("move_left","move_right")
	var isStill = is_zero_approx(direction) and is_zero_approx(velocity.x)
	
	match state:
		State.IDLE:
			if !isStill:
				return State.RUNNING
			if Input.is_action_just_pressed("attack"):
				return State.ATTACK
			if not is_on_floor():
				return State.FALL
			
		State.RUNNING:
			if isStill:
				return State.IDLE	
			if Input.is_action_just_pressed("attack"):
				return State.ATTACK
			if not is_on_floor():
				return State.FALL
	
		State.JUMP:
			if velocity.y >0:
				return State.FALL
		State.FALL:
			if is_on_floor():
				return State.LANDING
		State.LANDING:
			#if not animation_player.is_playing():
			return State.IDLE
		State.ATTACK:
			if not animation_player.is_playing():
				return State.IDLE
	return state


func transition_state(from:State,to:State) -> void:
	if from not in GROUND_STATES and to in GROUND_STATES:
		coyote_timer.stop()
	match to:
		State.IDLE:
			animation_player.play("idle")
		State.RUNNING:
			animation_player.play("move")
		State.JUMP:
			animation_player.play("jump")
			velocity.y = jumpVelocity
			coyote_timer.stop()
			jump_request_timer.stop()
				
		State.FALL:
			animation_player.play("fall")
			if from in GROUND_STATES:
				coyote_timer.start()
		State.LANDING:
			pass
		State.ATTACK:
			animation_player.play("attack")

