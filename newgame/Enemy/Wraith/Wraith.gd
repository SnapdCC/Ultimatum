extends KinematicBody2D

const fireball = preload("res://Enemy/Wraith/Fireball.tscn")

onready var playerPosition = get_parent().get_node("Player")
onready var enemyPosition = get_parent().get_node("Wraith")
onready var animationPlayer = $AnimationPlayer
onready var enemyHealth = get_node("./Health/HealthBar")
var maxHealth = 100
var health = 100

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
	enemyHealth.value = float((health / maxHealth) * 100.0)
	if (!isWalking and alive):
		tempAnim = "Idle"


func _physics_process(delta):
	self.z_index = self.position.y
	if(alive and !inStun):
		isWalking = true
		if (playerPosition.position.x > enemyPosition.position.x):
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
			if (canHit):
				tempAnim = "Fireball"
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
	

func _on_Punchbox_area_entered(area):
	if ((area.get_parent().get_node_or_null("player") != null) and (playerPosition.health > 0)):
		var charHurt = area.get_parent()
		
		charHurt.stunHit(25.0, 0.5)
		
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
		animationPlayer.playback_speed = 0.5 / stunFrame
		
		if tempAnim == "Hurt":
			animationPlayer.stop()
		
		tempAnim = "Hurt"
		


func _on_AnimationPlayer_animation_finished(anim_name):
	if (anim_name == "Punch"):
		$attackCooldown.start()
		canHit = false
		isPunching = false
		noWalk = false
	if (anim_name == "Fireball"):
		$attackCooldown.start()
		canHit = false
		isPunching = false
		noWalk = false
		var shoot = fireball.instance()
		shoot.position = get_child(0).position
		shoot.flip_X($Sprite.scale.x)
		add_child(shoot)
		print(shoot)
	if (anim_name == "Death"):
		queue_free()
		
	if (anim_name == "Hurt"):
		animationPlayer.playback_speed = 1
		inStun = false

func _on_attackCooldown_timeout():
	canHit = true


func _on_AnimationPlayer_animation_started(anim_name):
	if (anim_name == "Punch"):
		isPunching = true
