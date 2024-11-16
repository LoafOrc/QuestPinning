extends Node

signal pinned_quests_update

const MOD_ID := "me.loaforc.questpinning"
const SAVE_FILE := "user://questpinning.save"

var pinnedQuestsElement = null

var pin_button = load("res://mods/me.loaforc.questpinning/scenes/pin_button.tscn")
var extraDebugInfo := true

var pinnedQuests = []
var config = {}

func is_pinned(quest_id):
	return quest_id in pinnedQuests or int(quest_id) in pinnedQuests or str(quest_id) in pinnedQuests

func _pin_quest(quest_id):
	if is_pinned(quest_id):
		debug("bwaa quest_id already exists")
		return
	
	
	pinnedQuests.append(quest_id)
	debug("updating pinned quests")
	emit_signal("pinned_quests_update")

func _unpin_quest(quest_id):
	if !is_pinned(quest_id):
		debug("what, tried to unpin quest that isn't pinned")
		return
	
	pinnedQuests.erase(quest_id)
	debug("updating pinned quests")
	emit_signal("pinned_quests_update")

func debug(message):
	if config["DebugLogging"]:
		info("[Debug] %s" % message)

func info(message):
	print("[%s] %s" % [MOD_ID, message])


func _save_data():
	var data = JSON.print({"pinnedQuests": pinnedQuests})
	var file = File.new()
	if file.open(SAVE_FILE, File.WRITE) == OK:
		file.store_string(data)
		file.close()
		info("data saved!")
	else:
		info("data save fail!")

func _load_data():
	info("getting saved data")
	
	var file = File.new()
	if file.file_exists(SAVE_FILE):
		info("found saved data")

		file.open(SAVE_FILE, File.READ)
		var json_data = file.get_as_text()
		file.close()
		var parsed_data = parse_json(json_data)
		
		pinnedQuests = parsed_data["pinnedQuests"]
		debug("pinnedQuests: %s" % [pinnedQuests])
		
		return
	info("no existing questpinning save found, making a new one")
	
	pinnedQuests = []
	
	_save_data()

# Called when the node enters the scene tree for the first time.
func _ready():
	
	# fixme: THIS WILL BREAK WITH A MOD MANAGER
	# can safely assume that this has been created because it gets created in the c# assembly
	var exePath = OS.get_executable_path().get_base_dir()
	var path = exePath.plus_file("GDWeave").plus_file("configs").plus_file("me.loaforc.questpinning.json")
	
	var file = File.new()
	file.open(path, File.READ)
	var data = file.get_as_text()
	file.close()
	
	config = JSON.parse(data).result
	info("loaded config! %s" % [config])
	
	#########
	
	if config["SaveAndLoadData"]:
		_load_data()
		connect("pinned_quests_update", self, "_save_data")
	
	debug("path is: %s" % get_path())
	debug("type of str is %s and type of int is %s" % [typeof(""), typeof(0)])
	info("questpinning by loaforc has loaded :3")

func _physics_process(delta):
	if pinnedQuestsElement == null || !is_instance_valid(pinnedQuestsElement):
		var parent = get_tree().get_root().get_node_or_null("./playerhud/main/in_game")
		if parent != null && is_instance_valid(parent):
			
			info("quest element is not valid, adding to the player's hud now")
			
			pinnedQuestsElement = load("res://mods/me.loaforc.questpinning/PinnedQuests.tscn").instance()
			pinnedQuestsElement.name = "QuestPinning-PinnedQuestsElement"
			
			parent.add_child(pinnedQuestsElement)
			info("added the silly ui element :33")

func _quest_button_patch(quest_button, quest_id):
	debug("patch was called!!")
	debug("quest_id is %s with type %s" % [quest_id, typeof(quest_id)])
	
	var pin_button_instance = pin_button.instance()
	quest_button.add_child(pin_button_instance)
	
	
	pin_button_instance.quest_id = quest_id
	
	
	pin_button_instance._attach(quest_button)

# I FUCKING HATE GD SCRIPT
func try_get_quest(quest_id):
	debug("trying to get quest: %s type: %s" % [quest_id, typeof(quest_id)])
	var quest = PlayerData.current_quests[quest_id]
	if quest != null:
		debug("didn't need to change the type!")
		return quest
		
	quest = PlayerData.current_quests[int(quest_id)]
	if quest != null:
		debug("changing to int worked!!!")
		return quest
		
	quest = PlayerData.current_quests[str(quest_id)]
	if quest != null:
		debug("changed to str worked!!!")
		return quest
		
	# oh fuck
	info("Failed to get quest with id: %s" % quest_id)
	return null
