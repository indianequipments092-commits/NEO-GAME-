extends Node

## Phase 9 economy controller.
## Uses fictional, non-cash in-game Credits only. Real-money purchases and ad SDKs
## are intentionally abstracted behind safe hooks for later platform integration.
const SAVE_PATH := "user://economy.cfg"
var credits: int = 0
var total_earned: int = 0
var ad_reward_ready := true

func _ready() -> void:
    load_economy()

func add_credits(amount: int) -> void:
    if amount <= 0:
        return
    credits += amount
    total_earned += amount
    save_economy()

func spend_credits(amount: int) -> bool:
    if amount <= 0 or credits < amount:
        return false
    credits -= amount
    save_economy()
    return true

func get_credits() -> int:
    return credits

func claim_run_reward(survival_seconds: int) -> int:
    var reward := maxi(0, survival_seconds / 10)
    add_credits(reward)
    return reward

func claim_ad_reward_placeholder() -> int:
    ## Placeholder only. A real rewarded-ad provider should call this after its
    ## own verified completion callback and age/consent checks.
    if not ad_reward_ready:
        return 0
    ad_reward_ready = false
    var reward := 25
    add_credits(reward)
    return reward

func reset_ad_reward_placeholder() -> void:
    ad_reward_ready = true

func save_economy() -> void:
    var config := ConfigFile.new()
    config.set_value("economy", "credits", credits)
    config.set_value("economy", "total_earned", total_earned)
    config.save(SAVE_PATH)

func load_economy() -> void:
    var config := ConfigFile.new()
    if config.load(SAVE_PATH) == OK:
        credits = int(config.get_value("economy", "credits", 0))
        total_earned = int(config.get_value("economy", "total_earned", 0))
