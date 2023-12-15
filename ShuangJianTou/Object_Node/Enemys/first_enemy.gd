extends Enemy

enum State{
	IDLE,
	#JUMP,
	#FALL,
	MOVE,
	IDLE_TO_MOVE,
	MOVE_TO_IDLE,
	HURT,
	DYING,
}
var pending_damage:Damage	#带处理的伤害

@onready var wall_checker: RayCast2D = $Graphics/WallChecker
@onready var player_checker: RayCast2D = $Graphics/PlayerChecker
@onready var floor_checker: RayCast2D = $Graphics/FloorChecker
@onready var move_to_idle_timer: Timer = $Move_To_Idle_Timer
@onready var idle_to_move_timer: Timer = $Idle_To_Move_Timer


func tick_physics(state:State,delta:float) -> void:
	match state:
		State.IDLE,State.HURT,State.DYING:
			move(0,delta)
		State.IDLE_TO_MOVE:
			move(0,delta)
		State.MOVE:
			move(maxSpeed,delta)
			if not floor_checker.is_colliding():
				faceDirection *= -1
			if wall_checker.is_colliding():
				faceDirection *= -1
		State.MOVE_TO_IDLE:
			move(0,delta)
	

func get_next_state(state:State)->int:
	if stats.now_health == 0:
		return StateMachine.KEEP_CURRENT if state == State.DYING else State.DYING
	if pending_damage:
		return State.HURT
	
	match state:
		State.IDLE:
			if idle_to_move_timer.is_stopped() or player_checker.is_colliding():
				idle_to_move_timer.stop()
				return State.IDLE_TO_MOVE		
				
		State.IDLE_TO_MOVE:
			move_to_idle_timer.start()
			return State.MOVE	
			
		State.MOVE:
			if move_to_idle_timer.is_stopped():
				move_to_idle_timer.stop()
				return State.MOVE_TO_IDLE
				
		State.MOVE_TO_IDLE:
			idle_to_move_timer.start()
			return State.IDLE		
		
		State.HURT:#受伤逻辑存在问题，测试用
			if not animation_player.is_playing():
				return State.MOVE
			
		State.DYING:
			pass
			

	return StateMachine.KEEP_CURRENT
	

func transition_state(from:State,to:State) -> void:
	'''
	print("[%s] %s => %s" % [
		Engine.get_physics_frames(),
		State.keys()[from] if from != -1 else "<START>",
		State.keys()[to],
	])
	'''
	match to:
		State.IDLE:
			animation_player.play("idle")				
		State.IDLE_TO_MOVE:
			animation_player.play("idle_to_move")
		State.MOVE:
			animation_player.play("move")
		State.MOVE_TO_IDLE:
			animation_player.play("move_to_idle")		
		State.HURT:
			stats.now_health -= pending_damage.amount
			var dir := pending_damage.source.global_position.direction_to(global_position)
			velocity = dir * 500#击退效果
			if dir.x > 0:
				faceDirection = Direction.LEFT
			else:
				faceDirection = Direction.RIGHT
			pending_damage = null
			
		State.DYING:
			animation_player.play("hit")



func _on_hurtbox_hurt(hitbox: Hitbox) -> void:
	pending_damage = Damage.new()
	pending_damage.amount = 1
	pending_damage.source = hitbox.owner
