extends KinematicBody2D

onready var animationPlayer = $AnimationPlayer
onready var bossHealth = get_node("../CanvasLayer/BossUI/BossFrame/HealthBar")
var maxHealth = 200.0
var health = 200.0

var tempAnim
var anim_new
var isWalking = false
var alive = true
var dontLoop = false
var canHit = true
var isTaunting = false
var isPunching = false
var noWalk = false

onready var playerPosition = get_parent().get_node("Player")
var bossSpeed = 25
onready var bossPosition = get_parent().get_node("LimboBoss")


# Called when the node enters the scene tree for the first time.
func _ready():
	bossHealth.value = (health / maxHealth) * 100.0
	if (!isWalking and alive):
		tempAnim = "Idle"

func _physics_process(delta):
	if(alive):
		isWalking = true
		if (playerPosition.position.x > position.x):
			$Sprite.scale.x = -1
		else:
			$Sprite.scale.x = 1
			
		if ((bossPosition.position.x - playerPosition.position.x) <= 50 && (bossPosition.position.x - playerPosition.position.x) >= -50):
			isWalking = false
			if (canHit and !isTaunting):
				isPunching = true
				tempAnim = "Punch"
			else:
				if (tempAnim != "Taunt"):
					tempAnim = "Idle"
			
		else:
			if (isPunching or isTaunting):
				noWalk = true
			if(!noWalk):
				move_and_slide((playerPosition.position - (bossPosition.position - Vector2(0, 20))).normalized() * bossSpeed)
				tempAnim = "Walk"
				$attackCooldown.stop()
				canHit = true
	
		animationSwapper(tempAnim)

func animationSwapper(anim):
	anim_new = anim
	animationPlayer.play(anim)
	

func _on_HurtAreaLimboPunch_area_entered(area):
		if ((area.get_parent().get_node_or_null("player") != null) and (playerPosition.health > 0)):
			var charHurt = area.get_parent()
			
			
			charHurt.stunHit(50.0, 5.0)
		
			print(area.get_parent().name)
			
			if charHurt.health <= 0:
				tempAnim = "Taunt"
				isTaunting = true


func _on_LimboHitbox_area_entered(area):
	pass # Replace with function body.
	
func bossDie():
	animationPlayer.stop()
	animationPlayer.play("Death")

func stunHit(damageTake, stunFrame):
	health -= damageTake
	print(health / maxHealth)
	bossHealth.value = (health / maxHealth) * 100.0
		
	if (health <= 0):
		isWalking = false
		alive  = false
		dontLoop = true
		bossDie()

func _on_AnimationPlayer_animation_finished(anim_name):
	if (anim_name == "Punch"):
		$attackCooldown.start()
		canHit = false
		isPunching = false
		noWalk = false
	
	if (anim_name == "Death"):
		queue_free()
		
	if (anim_name == "Taunt"):
		isTaunting = false


func _on_attackCooldown_timeout():
	canHit = true
