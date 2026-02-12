# res://scenes/cards/CardUI.gd
class_name CardUI
extends Control

@export var card_data: Card = null

# Exact paths from the .tscn you provided
@onready var art: TextureRect = $Art
@onready var name_label: Label = $OuterMargin/CardFrame/MainStack/HeaderOverlay/Header/NameLabel
@onready var cost_label: Label = $OuterMargin/CardFrame/MainStack/HeaderOverlay/Header/CostLabel
@onready var cost_icon: TextureRect = $OuterMargin/CardFrame/MainStack/HeaderOverlay/Header/CostIcon
@onready var description_label: RichTextLabel = $OuterMargin/CardFrame/MainStack/DescriptionOverlay/DescMargin/DescriptionLabel

# New clean signal for BattleTemplate
signal card_clicked(card_ui: CardUI)

func _ready() -> void:
	update_display()

func update_display() -> void:
	if not card_data:
		if name_label: name_label.text = "No Card"
		if cost_label: cost_label.text = "-"
		if cost_icon: cost_icon.texture = null
		if description_label: description_label.text = "[center]No data[/center]"
		if art: art.texture = null
		return
	
	# Safe assignments
	if name_label:
		name_label.text = card_data.card_name
	
	if art:
		art.texture = card_data.art
	
	if cost_icon:
		cost_icon.texture = null  # clear first
	
	if card_data.cascade_cost > 0:
		if cost_label: cost_label.text = str(card_data.cascade_cost)
		if cost_icon:
			cost_icon.texture = preload("res://assets/art/ui/icons/cascade_orb.png")
	else:
		if cost_label: cost_label.text = str(card_data.mana_cost)
		if cost_icon:
			cost_icon.texture = preload("res://assets/art/ui/icons/mana_gem.png")
	
	if description_label:
		var desc = card_data.description if card_data.description else ""
		description_label.text = "[center]%s[/center]" % desc

# Click to play card (much cleaner than gui_input)
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		card_clicked.emit(self)

# Hover scaling (already connected in your .tscn)
func _on_mouse_entered() -> void:
	scale = Vector2(1.08, 1.08)

func _on_mouse_exited() -> void:
	scale = Vector2(1.0, 1.0)
