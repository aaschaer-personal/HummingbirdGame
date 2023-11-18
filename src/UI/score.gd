extends Label

func _ready():
	GameProgression.score_changed.connect(_on_score_changed)
	
func _on_score_changed(score):
	text = "SCORE: " + str(score)
