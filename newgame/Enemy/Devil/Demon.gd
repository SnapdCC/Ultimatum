extends KinematicBody2D

onready var playerPosition = get_parent().get_node("Player")
onready var enemyPosition = get_parent().get_node("Demon")
onready var animationPlayer = $AnimationPlayer
onready var enemyHealth = get_node("./Health/HealthBar")
var maxHealth = int(100)
var health = int(100)

var tempAnim
var anim_new
var isWalking = false
var alive = true
var dontLoop = false
var canHit = true
var isPunching = false
var noWalk = false
var inStun = false

var enemySpeed = 20

func _ready():
	enemyHealth.value = (health / maxHealth) * 100.0
	if (!isWalking and alive):
		tempAnim = "Idle"


func _physics_process(delta):
	self.z_index = self.position.y
	if(alive and !inStun):
		isWalking = true
		if (playerPosition.position.x > position.x):
			$Sprite.scale.x = 1
		else:
			$Sprite.scale.x = -1
			
		if ((enemyPosition.position.x - playerPosition.position.x) <= 50 && (enemyPosition.position.x - playerPosition.position.x) >= -50):
			isWalking = false
			if (canHit):
				isPunching = true
				tempAnim = "Punch"
			else:
				tempAnim = "Idle"
			
		else:
			if (isPunching):
				noWalk = true
			if(!noWalk):
				move_and_slide((playerPosition.position - (enemyPosition.position - Vector2(0, 20))).normalized() * enemySpeed)
				tempAnim = "Walk"
				$attackCooldown.stop()
				canHit = true
	
	animationSwapper(tempAnim)

func animationSwapper(anim):
	anim_new = anim
	animationPlayer.play(anim)
	

func _on_AttackArea_area_entered(area):
	if ((area.get_parent().get_node_or_null("player") != null) and (playerPosition.health > 0)):
		var charHurt = area.get_parent()
			
			
		charHurt.stunHit(10.0, 1)
func enemyDie():
	animationPlayer.stop()
	tempAnim = "Death"
	

func stunHit(damageTake, stunFrame):
	
	health -= damageTake
	print(health / maxHealth)
	enemyHealth.value = (health / maxHealth) * 100.0
	
	if (health <= 0):
		animationPlayer.playback_speed = 1
		isWalking = false
		inStun = false
		alive  = false
		dontLoop = true
		enemyDie()
	else:
		inStun = true
		animationPlayer.playback_speed = 1 / stunFrame
		
		if tempAnim == "Stun":
			animationPlayer.stop()
		
		tempAnim = "Stun"
		


func _on_AnimationPlayer_animation_finished(anim_name):
	if (anim_name == "Punch"):
		$attackCooldown.start()
		canHit = false
		isPunching = false
		noWalk = false
	
	if (anim_name == "Death"):
		queue_free()
		
	if (anim_name == "Stun"):
		animationPlayer.playback_speed = 1
		inStun = false

func _on_attackCooldown_timeout():
	canHit = true


func _on_AnimationPlayer_animation_started(anim_name):
	if (anim_name == "Punch"):
		isPunching = true
