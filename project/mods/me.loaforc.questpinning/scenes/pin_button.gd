extends TextureButton

onready var mod_node = get_node("/root/meloaforcquestpinning")

var quest_id = -1

func _update_pinned_status():
	if mod_node.is_pinned(quest_id):
		mod_node.debug("is pinned!")
		pressed = true
		_on_focus()
	else:
		mod_node.debug("is NOT pinned!")
		_on_blur()

func _ready():
	mod_node.connect("pinned_quests_update", self, "_update_pinned_status")
	mod_node.debug("attaching pin button, questid: %s type is %s" % [quest_id, typeof(quest_id)])
	_update_pinned_status()

func _attach(parent: Control):
	parent.connect("mouse_entered", self, "_on_focus")
	parent.connect("mouse_exited", self, "_on_blur")

func _on_focus():
	mod_node.debug("focused")
	visible = true

func _on_blur():
	if pressed and mod_node.is_pinned(quest_id):
		return
	
	mod_node.debug("blurred")
	visible = false

func _on_toggle(button_pressed):
	var quest = mod_node.try_get_quest(quest_id)
	
	if button_pressed:
		mod_node.info("pinned quest: %s (%s)" % [quest["title"], quest_id])
		mod_node._pin_quest(quest_id)
	else:
		mod_node.info("unpinned quest: %s (%s)" % [quest["title"], quest_id])
		mod_node._unpin_quest(quest_id)
