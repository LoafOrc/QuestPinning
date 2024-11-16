extends Control

###### THIS FILE IS AN ABOMINATION

var prev_amt := 0
var do_fade_out := false
var nextText := ""

onready var mod_node = get_node("/root/meloaforcquestpinning")
onready var playerhud = get_tree().get_root().get_node_or_null("./playerhud")

func fade_out():
	yield (get_tree().create_timer(0.5), "timeout")
	
	$Tween.stop_all()
	modulate.a = 1.0

	$HBoxContainer/VBoxContainer/RichTextLabel.bbcode_text = nextText

	$Tween.interpolate_property($Panel, "modulate:a", modulate.a, 0.3, 0.8, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.start()

func _ready():
	theme = load("res://Assets/Themes/panel_med.tres")
	
	var font = DynamicFont.new()
	font.size = 22
	font.font_data = load("res://Assets/Themes/coolvetica condensed rg.otf")
	
	$HBoxContainer/VBoxContainer/RichTextLabel.add_font_override("normal_font", font)
	
	playerhud.connect("_menu_entered", self, "_on_menu_enter")

func _on_menu_enter(menu):
	if menu == 0 and do_fade_out: # base ingame ui
		do_fade_out = false
		mod_node.debug("doing the fade out!!!")
		fade_out()

func _display(quest_id, delayTextChange = true):
	var quest = mod_node.try_get_quest(quest_id)
	if prev_amt != quest["progress"]:
		mod_node.debug("flagged for doing fade out")
		do_fade_out = true
		prev_amt = quest["progress"]
	
	
	
	nextText = "%s (%s/%s)" % [quest["title"], quest["progress"], quest["goal_amt"]]
	if not delayTextChange:
		$Panel.modulate.a = 0.3
		$HBoxContainer/VBoxContainer/RichTextLabel.bbcode_text = nextText
	
	$HBoxContainer/TextureRect.texture = load(quest["icon"])
