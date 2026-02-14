# res://scenes/ui/CardUI.gd
class_name CardUI
extends Control

@export var card_data: Card = null  # Assign this when creating the card

@onready var art: TextureRect = $Art
@onready var name_label: Label = $OuterMargin/CardFrame/MainStack/HeaderOverlay/Header/NameLabel
@onready var cost_label: Label = $OuterMargin/CardFrame/MainStack/HeaderOverlay/Header/CostLabel
@onready var cost_icon: TextureRect = $OuterMargin/CardFrame/MainStack/HeaderOverlay/Header/CostIcon
@onready var description_label: RichTextLabel = $OuterMargin/CardFrame/MainStack/DescriptionOverlay/DescMargin/DescriptionLabel

func _ready() -> void:
	update_display()

func update_display() -> void:
	if not card_data:
		name_label.text = "No Card"
		cost_label.text = "-"
		if cost_icon:
			cost_icon.texture = null
		description_label.text = "[center]Assign a card resource[/center]"
		art.texture = null
		return
	
	name_label.text = card_data.card_name
	art.texture = card_data.art
	
	# Clear previous icon to prevent overlay/ghosting
	if cost_icon:
		cost_icon.texture = null
	
	# Choose correct icon + number based on cost type
	if card_data.cascade_cost > 0:
		cost_label.text = str(card_data.cascade_cost)
		if cost_icon:
			cost_icon.texture = preload("res://assets/art/ui/icons/cascade_orb.png")
			  # orange/yellow glow for cascade
	else:
		cost_label.text = str(card_data.mana_cost)
		if cost_icon:
			cost_icon.texture = preload("res://assets/art/ui/icons/mana_gem.png")
			 # blue glow for mana
	
	# Description with basic centering
	description_label.text = "[center]" + card_data.description + "[/center]"

# Basic hover feedback
func _on_mouse_entered() -> void:
	scale = Vector2(1.08, 1.08)

func _on_mouse_exited() -> void:
	scale = Vector2(1.0, 1.0)
