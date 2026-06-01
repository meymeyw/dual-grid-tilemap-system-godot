extends CheckButton

@export var gridSprite : Sprite2D

func _on_toggled(toggledOn : bool):
	gridSprite.visible = toggledOn
