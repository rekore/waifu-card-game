# res://scripts/cards/CardDatabase.gd
class_name CardDatabase
extends Node

# Dictionary: id -> Card resource
var cards: Dictionary = {}

# Folder where .tres card files live
const CARDS_FOLDER: String = "res://resources/cards/"

func _ready() -> void:
	load_all_cards()

func load_all_cards() -> void:
	cards.clear()
	
	var dir := DirAccess.open(CARDS_FOLDER)
	if dir == null:
		push_error("CardDatabase: Cannot open folder %s" % CARDS_FOLDER)
		return
	
	dir.list_dir_begin()
	var file_name := dir.get_next()
	
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".tres"):
			var card_path := CARDS_FOLDER + file_name
			var card: Card = load(card_path) as Card
			if card and card.id != "":
				cards[card.id] = card
			else:
				push_warning("CardDatabase: Invalid or missing ID in %s" % card_path)
		file_name = dir.get_next()
	
	dir.list_dir_end()
	print("CardDatabase: Loaded %d cards" % cards.size())

# Helper functions
func get_card(id: String) -> Card:
	if cards.has(id):
		return cards[id].duplicate()  # Return a copy to prevent editing originals
	push_error("CardDatabase: Card not found: %s" % id)
	return null

func get_all_cards() -> Array[Card]:
	var result: Array[Card] = []
	for card in cards.values():
		result.append(card.duplicate())
	return result
