extends Control
class_name BattleTemplate

const CARD_UI_SCENE = preload("res://scenes/cards/CardUI.tscn")

# ──────────────────────────────────────────────────────────────────────────────
#   Core combat variables (CardRulesBible aligned)
# ──────────────────────────────────────────────────────────────────────────────
var player_hp: int = 80
var player_max_hp: int = 80
var player_block: int = 0

var energy: int = 0
var max_energy: int = 3

var cascade_points: int = 0
var current_element: String = "Neutral"

# Piles
var draw_pile: Array[Card] = []
var discard_pile: Array[Card] = []
var hand_nodes: Array[CardUI] = []

# Single active enemy for now
var enemy_hp: int = 60
var enemy_max_hp: int = 60

var is_player_turn: bool = true

# ──────────────────────────────────────────────────────────────────────────────
#   UI node references
# ──────────────────────────────────────────────────────────────────────────────
@onready var energy_label: Label = $BattleLayout/PlayerSection/PlayerBottomBar/EnergyContainer/EnergyHBoxContainer/EnergyLabel
@onready var hand_hbox: HBoxContainer = $BattleLayout/PlayerSection/PlayerBottomBar/HandContainer/HandHBox
@onready var end_turn_button: Button = $BattleLayout/PlayerSection/PlayerBottomBar/EndTurnContainer/EndTurnButton

@onready var player_hp_bar: ProgressBar = $BattleLayout/Battlefield/PlayerParty/PlayerHPBar
@onready var enemy_hp_bar: ProgressBar = $BattleLayout/Battlefield/EnemySide/EnemyHPBar
@onready var enemy_intent_label: Label = $BattleLayout/Battlefield/EnemySide/EnemyIntent

@onready var cascade_pips: Array[TextureRect] = [
	$BattleLayout/Battlefield/PlayerParty/CascadeMeter/pip0,
	$BattleLayout/Battlefield/PlayerParty/CascadeMeter/pip1,
	$BattleLayout/Battlefield/PlayerParty/CascadeMeter/pip2,
	$BattleLayout/Battlefield/PlayerParty/CascadeMeter/pip3,
	$BattleLayout/Battlefield/PlayerParty/CascadeMeter/pip4,
	$BattleLayout/Battlefield/PlayerParty/CascadeMeter/pip5,
	$BattleLayout/Battlefield/PlayerParty/CascadeMeter/pip6,
]

@onready var waifu_name_labels: Array[Label] = [
	$BattleLayout/Battlefield/PlayerParty/WaifuContainer/WaifuVBox/NameLabel,
	$BattleLayout/Battlefield/PlayerParty/WaifuContainer/WaifuVBox2/NameLabel,
	$BattleLayout/Battlefield/PlayerParty/WaifuContainer/WaifuVBox3/NameLabel,
]

@onready var waifu_portraits: Array[TextureRect] = [
	$BattleLayout/Battlefield/PlayerParty/WaifuContainer/WaifuVBox/Waifu1/Waifu1Portrait,
	$BattleLayout/Battlefield/PlayerParty/WaifuContainer/WaifuVBox2/Waifu2/Waifu2Portrait,
	$BattleLayout/Battlefield/PlayerParty/WaifuContainer/WaifuVBox3/Waifu3/Waifu3Portrait,
]

@onready var enemy_name_labels: Array[Label] = [
	$BattleLayout/Battlefield/EnemySide/EnemyContainer/EnemyVBox/EnemyName,
	$BattleLayout/Battlefield/EnemySide/EnemyContainer/EnemyVBox2/EnemyName,
	$BattleLayout/Battlefield/EnemySide/EnemyContainer/EnemyVBox3/EnemyName,
]

@onready var enemy_portraits: Array[TextureRect] = [
	$BattleLayout/Battlefield/EnemySide/EnemyContainer/EnemyVBox/Enemy/EnemyPortrait,
	$BattleLayout/Battlefield/EnemySide/EnemyContainer/EnemyVBox2/Enemy/EnemyPortrait,
	$BattleLayout/Battlefield/EnemySide/EnemyContainer/EnemyVBox3/Enemy/EnemyPortrait,
]

func _ready() -> void:
	load_test_deck()
	
	# Example setup — replace with real data later
	set_waifu(0, preload("res://icon.svg"), "Aiko")
	set_waifu(1, preload("res://icon.svg"), "Yumi")
	set_waifu(2, preload("res://icon.svg"), "Haruka")
	set_enemy(0, preload("res://icon.svg"), "Slime King", 70)
	
	reset_combat_state()
	start_player_turn()
	
	end_turn_button.pressed.connect(_on_end_turn_pressed)

func load_test_deck() -> void:
	var defend = preload("res://resources/cards/defend_basic.tres")
	for i in range(12):
		draw_pile.append(defend.duplicate())
	draw_pile.shuffle()

func load_deck_from_save(card_paths: Array[String]) -> void:
	draw_pile.clear()
	for path in card_paths:
		var card = load(path) as Card
		if card:
			draw_pile.append(card)
	draw_pile.shuffle()

func set_waifu(index: int, texture: Texture2D, display_name: String) -> void:
	if index < 0 or index > 2: return
	waifu_portraits[index].texture = texture
	waifu_name_labels[index].text = display_name

func set_enemy(index: int, texture: Texture2D, display_name: String, max_hp: int) -> void:
	if index < 0 or index > 2: return
	enemy_portraits[index].texture = texture
	enemy_name_labels[index].text = display_name
	if index == 0:
		enemy_max_hp = max_hp
		enemy_hp = max_hp
		enemy_hp_bar.max_value = max_hp
		enemy_hp_bar.value = max_hp

func reset_combat_state() -> void:
	player_block = 0
	cascade_points = 0
	current_element = "Neutral"
	energy = 0
	update_ui()

func start_player_turn() -> void:
	is_player_turn = true
	energy = max_energy
	draw_cards(5)
	update_ui()
	end_turn_button.disabled = false

func draw_cards(count: int) -> void:
	for i in count:
		if draw_pile.is_empty():
			reshuffle_discard()
		if draw_pile.is_empty():
			break
		
		var card_res: Card = draw_pile.pop_back()
		var card_ui: CardUI = CARD_UI_SCENE.instantiate()
		card_ui.card_data = card_res
		card_ui.update_display()
		
		# Use the new clean signal from CardUI
		card_ui.card_clicked.connect(_on_card_clicked.bind(card_ui))
		
		hand_hbox.add_child(card_ui)
		hand_nodes.append(card_ui)

func reshuffle_discard() -> void:
	draw_pile.append_array(discard_pile)
	discard_pile.clear()
	draw_pile.shuffle()

func _on_card_clicked(card_ui: CardUI) -> void:
	if is_player_turn:
		attempt_play_card(card_ui)

func attempt_play_card(card_ui: CardUI) -> void:
	var card: Card = card_ui.card_data
	if energy < card.mana_cost:
		# TODO: visual feedback (shake, red flash, sound)
		return
	
	energy -= card.mana_cost
	
	# Basic effect resolution (expand later)
	player_block += card.block if "block" in card else 0
	
	# Cascade gain (simple test version)
	var gain = 1 + (card.cascade_gain if "cascade_gain" in card else 0)
	cascade_points = mini(cascade_points + gain, 7)
	
	# Move to discard
	hand_hbox.remove_child(card_ui)
	hand_nodes.erase(card_ui)
	card_ui.queue_free()
	discard_pile.append(card)
	
	update_ui()

func _on_end_turn_pressed() -> void:
	if not is_player_turn: return
	is_player_turn = false
	end_turn_button.disabled = true
	
	discard_hand()
	player_block = 0
	
	enemy_turn()

func discard_hand() -> void:
	for card_ui in hand_nodes.duplicate():
		discard_pile.append(card_ui.card_data)
		hand_hbox.remove_child(card_ui)
		card_ui.queue_free()
	hand_nodes.clear()

func enemy_turn() -> void:
	var damage = 10
	var actual_damage = maxi(0, damage - player_block)
	player_hp -= actual_damage
	player_block = 0
	
	enemy_intent_label.text = "Attacking for %d" % damage
	
	update_ui()
	
	await get_tree().create_timer(1.2).timeout
	enemy_intent_label.text = "Intent"
	start_player_turn()

func update_ui() -> void:
	energy_label.text = "%d / %d" % [energy, max_energy]
	player_hp_bar.value = player_hp
	enemy_hp_bar.value = enemy_hp
	
	for i in 7:
		var pip = cascade_pips[i]
		if i < cascade_points:
			pip.modulate = Color(1.45, 1.25, 0.75, 1.0)  # gold
		else:
			pip.modulate = Color(0.6, 0.6, 0.6, 0.5)     # dim
