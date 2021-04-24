extends KinematicBody2D

onready var playerPosition = get_parent().get_node("Player")
export var speed = 50

func _physics_process(delta):
	self.z_index = self.position.y
	move_and_slide(Vector2.RIGHT * speed * self.scale.x * delta)

func _on_area_entered(area):
	if ((area.get_parent().get_node_or_null("player") != null) and (playerPosition.health > 0)):
		var charHurt = area.get_parent()
			
		charHurt.stunHit(25.0, 0.5)
		self.queue_free()

func flipX(x_scale):
	self.scale.x = x_scale
