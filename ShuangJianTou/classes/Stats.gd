'''
* 文件名：Stats
* 文件类型：共用类
* 文件功能：存储游戏对象的统计息[生命值：HP，攻击力：ATK]
* 使用方法：
'''
class_name Stats
extends Node

@export var max_health:int = 3
@onready var now_health:int = max_health:
	set(v):
		v = clampi(v,0,max_health)
		if now_health == v:
			return
		else:
			now_health = v
