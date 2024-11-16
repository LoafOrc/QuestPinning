extends Button

onready var mod_node = get_node("/root/meloaforcquestpinning")

func _on_button_pressed():
	mod_node.info("clearing pinned quests")
	mod_node.pinnedQuests.clear()
	mod_node.emit_signal("pinned_quests_update")
