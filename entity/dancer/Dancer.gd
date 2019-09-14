extends Sprite

export(Texture) var DANCER_SPRITE
export(int) var FRAME_COUNT

var counter = 0

func _ready():
	self.texture = DANCER_SPRITE
	self.hframes = FRAME_COUNT
	self.frame = counter

func move(step=counter):
	counter = (step + 1) % FRAME_COUNT
	self.frame = step % FRAME_COUNT