extends Node

## Phase 6 module and meta-progression controller.
var module_levels := {
	"engine": 0,
	"core": 0,
	"drone": 0
}
var meta_cores := 0

func install_module(module_name: String) -> bool:
	if not module_levels.has(module_name):
		return false
	module_levels[module_name] += 1
	return true

func get_module_level(module_name: String) -> int:
	return int(module_levels.get(module_name, 0))

func add_meta_cores(amount: int) -> void:
	meta_cores = maxi(0, meta_cores + amount)
