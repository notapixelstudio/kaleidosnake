extends Node2D

class_name Food

func _ready():
	pass

func die():
	queue_free()

func appear():
	$AnimationPlayer.play("appear")
	yield($AnimationPlayer, "animation_finished")
	$AnimationPlayer.play("rotate")