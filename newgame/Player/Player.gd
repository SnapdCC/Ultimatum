extends KinematicBody2D
signal walls

export var speed = 220
var screen_size

var health = 100
var maxHealth = 100
onready var zeraHealth:TextureProgress = get_node("../CanvasLayer/ZeraUI/Frame/HealthBar")

var meter:float = 0.0
export var maxMeter:float = 100.0
onready var zeraMeter:TextureProgress = get_node("../CanvasLayer/ZeraUI/Frame/SpecialBar")

var isPunching = false
var canDoubleHit = false
var isDoubleHitActive = false
var isKicking = false
var isGuarding = false
var canHit = true
var inStun = false
var isSuper = false
var isDead = false
var lose = false

var beginning = Dialogic.start('beginning')

var holder
var facing_right = true
var moveFrameArray = [
	[load("res://Player/Sprites/PunchSpriteSheet.png"), Rect2(Vector2(629, 0), Vector2(77, 100)),
	Rect2(Vector2(787, 3), Vector2(63, 97))] 
]

var tempAnim
var anim_new
onready var animationPlayer = $AnimationPlayer


# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	zeraHealth.value = clamp(health / maxHealth * 100.0, 0, 100)
	zeraMeter.value = clamp(meter/maxMeter * 100.0, 0, 100)
	
func _physics_process(delta):
	self.z_index = self.position.y
	var velocity = Vector2.ZERO
	


# watches for specific frames to see when one can input punch a second time to make the double punch
	if ($Sprite.texture == moveFrameArray[0][0]):
		if ($Sprite.region_rect == moveFrameArray[0][1] or $Sprite.region_rect == moveFrameArray[0][2]):
			if (Input.is_action_just_pressed("punch") and canDoubleHit and !isDead):
				isDoubleHitActive = true
				anim_new = "Double Punch"
				canDoubleHit = false
				canHit = false
				doubleHitPlay()
				$attackCooldown.start()
	else:
		canDoubleHit = false

# watches for punch and if double punch is available
	if (Input.is_action_just_pressed("punch") and !isSuper and !isDoubleHitActive and !isKicking and !isGuarding and !inStun and !isDead and canHit):
		canDoubleHit = true
		isPunching = true
		tempAnim = "Punch"
		canHit = false
		
		#plays kick animation and attack
	if (Input.is_action_just_pressed("kick") and !isSuper and !isDoubleHitActive and !isPunching and !isGuarding and !inStun and !isDead):
		if (isPunching):
			isPunching = false
		isKicking = true
		tempAnim = "Heavy Attack"
		
	if (Input.is_action_just_pressed("guard") and !isSuper and !isPunching and !isKicking and !inStun and !isDead):
		isGuarding = true
		tempAnim = "Guard"
		
	if (Input.is_action_just_pressed("super") and !isSuper and !isPunching and !isKicking and !inStun and !isDead):
		if (meter == maxMeter):
			meter = 0
			isSuper = true
			tempAnim = "Special"
		
	if (!isPunching and !isKicking and !isGuarding and !inStun and !isDead and !isSuper):
		if Input.is_action_pressed("ui_right"):
			velocity.x += 1
		if Input.is_action_pressed("ui_left"):
			velocity.x -= 1
		if Input.is_action_pressed("ui_down"):
			velocity.y += 1
		if Input.is_action_pressed("ui_up"):
			velocity.y -= 1
		if velocity != Vector2.ZERO:
			tempAnim = "Walk"
			if (velocity.x < -0.1):
				facing_right = false
				$Sprite.scale.x = -1
			elif (velocity.x > 0.1):
				facing_right = true
				$Sprite.scale.x = 1
			
		else:
			tempAnim = "Idle"
			if facing_right:
				$Sprite.scale.x = 1
			else:
				$Sprite.scale.x = -1
	
	velocity = move_and_slide(velocity * speed)
	
	#Checking on every frame, not every key
	animationSwapper(tempAnim)
	
# Swaps animations properly and doesn't override them with multiple inputs
func animationSwapper(anim):
	if (anim != anim_new and !isDoubleHitActive):
		anim_new = anim
		animationPlayer.play(anim)

func playerDeath():
	animationPlayer.stop()
	animationPlayer.play("Death")
	$transition.start()


func loseTransition():
	get_tree().change_scene("res://Screens/LoseScreen.tscn")
	

#double punch playing function
func doubleHitPlay():
	animationPlayer.stop()
	animationPlayer.play("Double Punch")

# finishes animations so they don't loop or get stuck
func _on_AnimationPlayer_animation_finished(anim_name):
	if (anim_name == "Punch"):
		isPunching = false
		canHit = true
	elif (anim_name == "Double Punch"):
		isPunching = false
		isDoubleHitActive = false
	elif (anim_name == "Heavy Attack"):
		isKicking = false
	elif (anim_name == "Guard"):
		isGuarding = false
	elif (anim_name == "Hurt"):
		animationPlayer.playback_speed = 1
		inStun = false
	elif (anim_name == "Special"):
		isSuper = false

func stunHit(damageTake, stunFrame):
	
	if (isGuarding):
		health -= (damageTake / 2)
	else:
		health -= damageTake
		
	print(health / maxHealth)
	
	zeraHealth.value = (health / maxHealth) * 100.0
	
	if (health <= 0):
		animationPlayer.playback_speed = 1
		isDead = true
		playerDeath()
		
	if (isSuper):
		tempAnim = "Super"
		
	else:
		if(!isGuarding):
			animationPlayer.stop()
			
			isPunching = false
			isKicking = false
			isDoubleHitActive = false
			
			inStun = true
			
			animationPlayer.playback_speed = 1 / stunFrame
			
			if (tempAnim != "Hurt"):
				tempAnim = "Hurt"
				
			if (inStun):
				animationPlayer.stop()
			
	

# if an attack lands
func _on_HurtArea_area_entered(area):
	
	if (area.get_parent().get_node_or_null("enemy") != null):
		var charHurt = area.get_parent()
		
		if (charHurt.health > 0 and isPunching):
			meter += 15
			charHurt.stunHit(25.0, .75)
			$HitSoundPunch.play()
			$SoundDurationPunch.start()
			
		elif (charHurt.health > 0 and isKicking):
			meter += 25
			charHurt.stunHit(50.0, 1.75)
			$HitSoundKick.play()
			$SoundDurationKick.start()
			
		elif (charHurt.health > 0 and isSuper):
			charHurt.stunHit(100.0, 2.5)
			
		print(meter)
	
	if (area.get_parent().get_node_or_null("boss") != null):
		meter = meter+25.0
		zeraMeter.set_value(clamp(meter/maxMeter*100.0, 0, 100))
		print(zeraMeter.value)
		var charHurt = area.get_parent()
		
		if (charHurt.health > 0 and isPunching):
			meter += 7
			charHurt.stunHit(5.0, .75)
			$HitSoundPunchBoss.play()
			$SoundDurationPunchBoss.start()
			
		elif (charHurt.health > 0 and isKicking):
			meter += 15
			charHurt.stunHit(10.0, 1.75)
			$HitSoundKickBoss.play()
			$SoundDurationKickBoss.start()
	
	if (meter > maxMeter):
		meter= maxMeter
	
	zeraMeter.value = (meter * 100.0 / maxMeter)


func _on_Area2D_area_entered(area):
	pass


func _on_AnimationPlayer_animation_started(anim_name):
		if (anim_name == "Punch"):
			isPunching = true
		if (anim_name == "Double Punch"):
			isPunching = true
		if (anim_name == "Heavy Attack"):
			isKicking = true
		if (anim_name == "Special"):
			isSuper = true


func _on_transition_timeout():
	loseTransition()


func _on_SoundDurationKick_timeout():
	$HitSoundKick.stop()


func _on_SoundDurationPunchBoss_timeout():
	$HitSoundPunchBoss.stop()


func _on_SoundDurationKickBoss_timeout():
	$HitSoundKickBoss.stop()


func _on_SoundDurationPunch_timeout():
	$HitSoundPunch.stop()


func _on_attackCooldown_timeout():
	canHit = true
	canDoubleHit = true
