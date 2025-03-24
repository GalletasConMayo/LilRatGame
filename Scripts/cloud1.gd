extends ParallaxLayer

var cloud_speed : int = -15
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	self.motion_offset.x += cloud_speed * delta
