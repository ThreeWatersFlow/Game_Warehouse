class_name Hitbox
extends Area2D

#攻击 判定框

signal hit(hurtbox)

func _init() -> void:
	area_entered.connect(_on_area_entered)



func _on_area_entered(hurtbox:Hurtbox)->void:
	print("[受伤!] %s 攻击 %s" % [owner.name,hurtbox.owner.name])
	hit.emit(hurtbox)
	hurtbox.hurt.emit(self)
	
	
