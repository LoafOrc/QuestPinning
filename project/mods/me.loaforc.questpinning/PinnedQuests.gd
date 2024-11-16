extends Control

var UIElement = load("res://mods/me.loaforc.questpinning/scenes/pinned_quest.tscn")
var ClearPinButton = load("res://mods/me.loaforc.questpinning/scenes/reset_pins.tscn")
onready var mod_node = get_node("/root/meloaforcquestpinning")
onready var playerhud = get_tree().get_root().get_node_or_null("./playerhud")

var currentPinButton = null

var shown = []

func _sort_by_progress(a, b):
	return PlayerData.current_quests[b]["progress"] / PlayerData.current_quests[b]["goal_amt"] < PlayerData.current_quests[a]["progress"] / PlayerData.current_quests[a]["goal_amt"]

# Called when the node enters the scene tree for the first time.
func _ready():
	PlayerData.connect("_quest_update", self, "_display")
	mod_node.connect("pinned_quests_update", self, "_display")
	playerhud.connect("_menu_entered", self, "_on_menu_enter")
	
	mod_node.debug("checking quest ids are valid, current_quests (%s): %s" % [PlayerData.current_quests.size(), str(PlayerData.current_quests.keys())])
	for quest_id in mod_node.pinnedQuests:
		if mod_node.try_get_quest(quest_id) != null:
			mod_node.debug("quest_id exists!")
			continue
		
		mod_node.info("bwaaa unknown quest id (%s), save probably changed so you can ignore this (unless you havent, then oh no)!" % quest_id)
		PlayerData._send_notification("QuestPinning: unknown quest id, reset your pinned quests!", 1)
		mod_node.pinnedQuests.clear()
		mod_node._save_data()
		break
	
	_display()

func _on_menu_enter(menu):
	mod_node.debug("_on_menu_enter: %s, shop id: %s" % [menu, playerhud.shop_id])
	
	if menu == 5 and playerhud.shop_id == "quest_board":
		var shopNode : Control = playerhud.shop
		if shopNode == null:
			mod_node.info("failed to place clear pins button!")
			return
		
		currentPinButton = ClearPinButton.instance()
		shopNode.add_child(currentPinButton)
		
		mod_node.info("placed clear pin button!")
	elif currentPinButton != null:
		mod_node.info("destorying clear pin button.")
		currentPinButton.queue_free()

func _filter_existing_quests(value):
	var quest = value
	if quest != null:
		mod_node.debug("quest: %s does exist!" % value)
	else:
		mod_node.debug("quest: %s does NOT exist! filtering out..." % value)
	return mod_node.try_get_quest(value) != null

func _display():
	var quest_keys = mod_node.pinnedQuests
	var filtered_array = []
	
	for value in quest_keys:
		if _filter_existing_quests(value):
			filtered_array.append(value)

	filtered_array.sort_custom(self, "_sort_by_progress")
	mod_node.pinnedQuests = filtered_array

	# hide the entire element if there are no quest keys
	if filtered_array.size() == 0:
		visible = false
		return
	else:
		visible = true

	mod_node.debug("_display: ensuring size")
	# make sure shown pool has enough elements
	while shown.size() < filtered_array.size():
		mod_node.debug("pooled new ui element")
		var new_element = UIElement.instance()
		$ItemContainer.add_child(new_element)
		shown.append(new_element)

	var i = 0
	for quest_id in filtered_array:
		mod_node.debug("displaying quest: %s" % mod_node.try_get_quest(quest_id)["title"])
		shown[i]._display(int(quest_id), false)
		shown[i].visible = true
		
		i += 1
	
	# hide the rest
	while i < shown.size():
		mod_node.debug("making element %s not visible" % i)
		shown[i].visible = false
		i += 1

	
