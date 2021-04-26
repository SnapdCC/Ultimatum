extends KinematicBody2D

onready var animationPlayer = $AnimationPlayer
onready var bossHealth = get_node_or_null("../CanvasLayer/BossUI/BossFrame/HealthBar")
onready var Arrow = get_parent().get_node("Level_Transitioner")
onready var Right_Wall = get_parent().get_node("BackgroundColliders").get_child(1)
var maxHealth = 200.0
var health = 200.0

var tempAnim
var anim_new
var isWalking = false
var isCharging = false
var alive = true
var dontLoop = false
var canHit = true
var isTaunting = false
var isPunching = false
var noWalk = false
var inStun = false
var attackGenerator = RandomNumberGenerator.new()
var attackChoice = attackGenerator.randf_range(1, 3)

onready var playerPosition = get_parent().get_node("Player")
var bossSpeed = 25
onready var bossPosition = get_parent().get_node("LimboBoss")


# Called when the node enters the scene tree for the first time.
func _ready():
	bossHealth.value = (health / maxHealth) * 100.0
	if (!isWalking and alive):
		tempAnim = "Idle"

func _physics_process(delta):
	if(alive and !inStun):
		isWalking = true
		if (playerPosition.position.x > position.x):
			$Sprite.scale.x = 1
		else:
			$Sprite.scale.x = -1
			
		if ((self.position.x - playerPosition.position.x) <= 50 && (self.position.x - playerPosition.position.x) >= -50):
			isWalking = false
			if (canHit and !isTaunting):
				if (attackChoice > 6):
					isCharging = true
					tempAnim = "Charge"
				else:
					isPunching = true
					tempAnim = "Punch"
			else:
				if (tempAnim != "Taunt"):
					tempAnim = "Idle"
			
		else:
			if (isPunching or isTaunting or isCharging):
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
			
		if charHurt.health <= 0:
			tempAnim = "Taunt"
			isTaunting = true
		
		if(isPunching):
			charHurt.stunHit(15.0, 0.25)
			
		elif(isCharging):
			charHurt.stunHit(20.0, .1)
		
		if (isPunching):
			$HitSoundPunch.play()
			$SoundDurationPunch.start()
		
		if (isCharging):
			$HitSoundCharge.play()
			$SoundDurationCharge.start()



func _on_LimboHitbox_area_entered(area):
	pass # Replace with function body.
	
func bossDie():
	#get_tree().change_scene("res://Screens/WinScreen.tscn")
	if Arrow != null:
		print("Arrow Found")
		Arrow.set_visible(true)
	else:
		print("Arrow notFound")
	if Right_Wall != null:
		print("Wall Found")
		Right_Wall.set_disabled(true)
	else:
		print("Wall not Found")
	animationPlayer.stop()
	tempAnim = "Death"

func stunHit(damageTake, stunFrame):
	health -= damageTake
	bossHealth.value = (health / maxHealth) * 100.0
		
	
	if (health <= 0):
		animationPlayer.playback_speed = 1
		isWalking = false
		isCharging = false
		inStun = false
		alive  = false
		dontLoop = true
		bossDie()
	else:
		if (!isCharging):
			inStun = true
			animationPlayer.playback_speed = 1 / stunFrame
		
			isPunching = false
			tempAnim = "Hurt"


func _on_AnimationPlayer_animation_finished(anim_name):
	if (anim_name == "Punch"):
		$attackCooldown.start()
		canHit = false
		isPunching = false
		isCharging = false
		noWalk = false
		attackChoice = attackGenerator.randf_range(1, 10)
	
	if (anim_name == "Death"):
		queue_free()
		
	if (anim_name == "Taunt"):
		tempAnim = "Idle"
		
	if (anim_name == "Charge"):
		$attackCooldown.start()
		canHit = false
		isCharging = false
		isPunching = false
		noWalk = false
		attackChoice = attackGenerator.randf_range(1, 10)
		
		
	if (anim_name == "Hurt"):
		animationPlayer.playback_speed = 1
		inStun = false


func _on_attackCooldown_timeout():
	canHit = true


func _on_AnimationPlayer_animation_started(anim_name):
		if (anim_name == "Punch"):
			isPunching = true
		elif (anim_name == "Charge"):
			isCharging = true


func _on_SoundDurationPunch_timeout():
	$HitSoundPunch.stop()


func _on_SoundDurationCharge_timeout():
	$HitSoundCharge.stop()
