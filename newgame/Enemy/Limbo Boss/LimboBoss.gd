extends KinematicBody2D

onready var animationPlayer = $AnimationPlayer
onready var bossHealth = $"../CanvasLayer/BossHealth/HealthBar"
var maxHealth = 200.0
var health = 200.0

var tempAnim
var anim_new
var isWalking = false
var alive = true

onready var playerPosition = get_parent().get_node("Player")
var bossSpeed = 25
onready var bossPosition = get_parent().get_node("LimboBoss")


# Called when the node enters the scene tree for the first time.
func _ready():
	bossHealth.value = (health / maxHealth) * 100
	if (!isWalking):
		tempAnim = "Idle"
	animationSwapper(tempAnim)

func _physics_process(delta):
	if(alive):
		if (playerPosition.position.x > position.x):
			$Sprite.scale.x = -1
		else:
			$Sprite.scale.x = 1
		isWalking = true
		move_and_slide((playerPosition.position - (bossPosition.position - Vector2(0, 20))).normalized() * bossSpeed)
		tempAnim = "Walk"


func animationSwapper(anim):
	anim_new = anim
	animationPlayer.play(anim)


func _on_HurtAreaLimboPunch_area_entered(area):
	pass # Replace with function body.


func _on_LimboHitbox_area_entered(area):
	pass # Replace with function body.

func stunHit(damageTake, stunFrame):
	health -= 5
	print(health / maxHealth)
	bossHealth.value = (health / maxHealth) * 100
	

	if (health <= 0):
		animationPlayer.play("Death")
		alive  = false
		
