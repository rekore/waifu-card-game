# res://scripts/cards/Card.gd  ← Updated with cascade_gain
@tool
class_name Card
extends Resource

@export var id: String = ""
@export var card_name: String = "Unnamed Card"
@export var art: Texture2D
@export var portrait: Texture2D

@export_category("Card Type")
@export var type: String = "Attack"  # Attack, Defense, Skill, Power, etc.

@export_category("Costs")
@export var mana_cost: int = 1       # Standard mana. Set to 0 for cascade-only cards
@export var cascade_cost: int = 0    # Cascade points cost. Set to 0 for mana-only cards

@export_category("Cascade Mechanics")  # NEW CATEGORY
@export var cascade_gain: int = 1    # NEW: Points added to cascade meter on play/resolve (default 1 for mana cards; 0 for finishers)
@export var element: String = "neutral"  # "neutral", "fire", "water", "earth", "wind" – only gains if matches chain

@export_category("Basic Stats (optional)")
@export var damage: int = 0
@export var block: int = 0
@export var draw_cards: int = 0

@export_category("Description")
@export_multiline var description: String = ""

func _init() -> void:
	if id == "":
		id = card_name.to_lower().replace(" ", "_")
