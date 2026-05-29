extends StaticBody3D

@onready var upgrade_gui = $UpgradeGUI

func get_interaction_text() -> String:
	return "Press E or Click to open Upgrades"

func interact(player):
	if upgrade_gui:
		upgrade_gui.open(player)
