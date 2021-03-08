extends KinematicBody2D
class_name actor

# variables
export var speed:  = Vector2(250, 250)
export var gravity = 0
var velocity: = Vector2.ZERO

# this makes the character move
func _physics_process(delta: float) -> void:
	velocity = move_and_slide(velocity)
