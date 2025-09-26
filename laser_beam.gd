extends RayCast2D

@onready var line_2d: Line2D = $Line2D
@onready var damage_timer: Timer = $DamageTimer

const DAMAGE_AMOUNT = 15
var current_target = null

func _ready():
	damage_timer.timeout.connect(_on_damage_timer_timeout)

func _physics_process(_delta):
	var cast_point = get_target_position()
	force_raycast_update()

	var new_target = null
	if is_colliding():
		var collider = get_collider()
		cast_point = to_local(get_collision_point())
		
		if collider.is_in_group("enemies"):
			new_target = collider
	
	line_2d.points = [Vector2.ZERO, cast_point]

	if new_target != current_target:
		current_target = new_target
		damage_timer.stop()
	
	if current_target and damage_timer.is_stopped():
		_on_damage_timer_timeout()
		damage_timer.start()

func _on_damage_timer_timeout():
	if is_instance_valid(current_target):
		current_target.take_damage(DAMAGE_AMOUNT)
