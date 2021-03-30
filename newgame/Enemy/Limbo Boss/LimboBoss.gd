extends Navigation2D

onready var animationPlayer = $AnimationPlayer
onready var bossHealth = $"../CanvasLayer/BossHealth/HealthBar"
var maxHealth = 200.0
var health = 200.0

# Called when the node enters the scene tree for the first time.
func _ready():
	bossHealth.value = (health / maxHealth) * 100


func _on_HurtAreaLimboPunch_area_entered(area):
	pass # Replace with function body.


func _on_LimboHitbox_area_entered(area):
	pass # Replace with function body.

func stunHit(damageTake, stunFrame):
	health -= 3
	print(health / maxHealth)
	bossHealth.value = (health / maxHealth) * 100
