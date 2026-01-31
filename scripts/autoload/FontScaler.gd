# res://scripts/autoload/FontScaler.gd
extends Node

# Your design resolution (what looks perfect in editor, e.g., 1920x1080 window)
@export var reference_resolution: Vector2 = Vector2(1920, 1080)

# Base font sizes matching your theme variations (editor values)
@export_group("Label/Text Sizes")
@export var base_largest: int = 140
@export var base_large: int = 84
@export var base_medium: int = 48
@export var base_small: int = 32
@export var base_smallest: int = 24

@export_group("Button Sizes")
@export var base_button_large: int = 72
@export var base_button_medium: int = 48   # default Button
@export var base_button_small: int = 32

# Minimum size to keep text readable even on very small screens
const MIN_FONT_SIZE: int = 14

func _ready() -> void:
	get_tree().root.size_changed.connect(_on_window_resized)
	_on_window_resized()  # Apply immediately on game start

func _on_window_resized() -> void:
	var viewport: Viewport = get_viewport()
	var viewport_size: Vector2 = viewport.get_visible_rect().size
	var scale_factor: float = min(
		viewport_size.x / reference_resolution.x,
		viewport_size.y / reference_resolution.y
	)
	
	# Calculate scaled sizes with minimum readable thresholds
	var largest   := maxi(MIN_FONT_SIZE, int(base_largest   * scale_factor))
	var large     := maxi(MIN_FONT_SIZE, int(base_large     * scale_factor))
	var medium    := maxi(MIN_FONT_SIZE, int(base_medium    * scale_factor))
	var small     := maxi(MIN_FONT_SIZE, int(base_small     * scale_factor))
	var smallest  := maxi(MIN_FONT_SIZE, int(base_smallest  * scale_factor))
	
	var btn_large   := maxi(MIN_FONT_SIZE, int(base_button_large   * scale_factor))
	var btn_medium  := maxi(MIN_FONT_SIZE, int(base_button_medium  * scale_factor))
	var btn_small   := maxi(MIN_FONT_SIZE, int(base_button_small   * scale_factor))
	
	# Apply to all relevant nodes in the current scene tree
	_apply_scaling_to_tree(get_tree().root, {
		"Largest": largest,
		"Large": large,
		"Medium": medium,
		"Small": small,
		"Smallest": smallest,
		"ButtonLarge": btn_large,
		"Button": btn_medium,      # default Button variation
		"ButtonSmall": btn_small
	})

func _apply_scaling_to_tree(node: Node, size_map: Dictionary) -> void:
	if node is Control:
		var variation: String = node.get_theme_type_variation()
		var target_size: int = 0
		
		if variation in size_map:
			target_size = size_map[variation]
		elif node is Label:
			# Fallback for plain Labels (use Medium if no variation)
			target_size = size_map["Medium"]
		elif node is Button:
			# Fallback for plain Buttons
			target_size = size_map["Button"]
		
		if target_size > 0:
			node.add_theme_font_size_override("font_size", target_size)
	
	# Recurse through all children
	for child in node.get_children():
		_apply_scaling_to_tree(child, size_map)
