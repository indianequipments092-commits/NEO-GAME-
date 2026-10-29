extends Node

signal status_changed(message: String)

const MANIFEST_URL := "https://github.com/indianequipments092-commits/NEO-GAME-/releases/latest/download/update-manifest.json"
const TRUSTED_RELEASE_PREFIX := "https://github.com/indianequipments092-commits/NEO-GAME-/releases/download/"
const PLUGIN_NAME := "NeonAndroidUpdater"

var _http: HTTPRequest
var _button: Button
var _status: Label
var _manifest: Dictionary = {}
var _download_path := ""
var _mode := "idle"
var _update_available := false
var _latest_version := ""
var _current_version := ""
var _platform_key := ""

func _ready() -> void:
	_current_version = str(ProjectSettings.get_setting("application/config/version", "0.2.0"))
	_platform_key = _get_platform_key()
	_http = HTTPRequest.new()
	_http.timeout = 45.0
	_http.max_redirects = 8
	_http.body_size_limit = 0
	_http.request_completed.connect(_on_request_completed)
	add_child(_http)

func attach_to_hud(layer: CanvasLayer) -> void:
	_button = Button.new()
	_button.name = "UpdateButton"
	_button.text = "CHECK UPDATE"
	_button.size = Vector2(176, 42)
	_button.add_theme_font_size_override("font_size", 15)
	_button.pressed.connect(_on_update_button_pressed)
	layer.add_child(_button)

	_status = Label.new()
	_status.name = "UpdateStatus"
	_status.size = Vector2(300, 36)
	_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_status.add_theme_font_size_override("font_size", 13)
	_status.add_theme_color_override("font_color", Color(0.8, 0.92, 1.0))
	layer.add_child(_status)
	_layout_controls()
	get_viewport().size_changed.connect(_layout_controls)
	check_for_updates()

func _layout_controls() -> void:
	if not is_instance_valid(_button) or not is_instance_valid(_status):
		return
	var viewport_size := get_viewport().get_visible_rect().size
	_button.position = Vector2(viewport_size.x - 194.0, 18.0)
	_status.position = Vector2(viewport_size.x - 320.0, 62.0)

func _get_platform_key() -> String:
	match OS.get_name():
		"Android":
			return "android"
		"Windows":
			return "windows"
		_:
			return ""

func check_for_updates() -> void:
	if _mode == "manifest" or _mode == "download":
		return
	if _platform_key.is_empty():
		_set_status("Updates: Android/Windows only")
		return
	_mode = "manifest"
	_set_status("Checking for updates…")
	var err := _http.request(MANIFEST_URL, PackedStringArray(["Accept: application/json"]), HTTPClient.METHOD_GET)
	if err != OK:
		_mode = "idle"
		_set_status("Update check could not start")
		push_warning("Updater manifest request failed to start: %s" % error_string(err))

func _on_update_button_pressed() -> void:
	if _mode == "download":
		return
	if _update_available:
		_download_update()
	else:
		check_for_updates()

func _on_request_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if _mode == "manifest":
		_handle_manifest_response(result, response_code, body)
	elif _mode == "download":
		_handle_download_response(result, response_code)

func _handle_manifest_response(result: int, response_code: int, body: PackedByteArray) -> void:
	_mode = "idle"
	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		_set_status("Update check failed — retry")
		return
	var parsed: Variant = JSON.parse_string(body.get_string_from_utf8())
	if not (parsed is Dictionary):
		_set_status("Invalid update manifest")
		return
	var manifest: Dictionary = parsed
	var version := str(manifest.get("version", ""))
	var platform_data: Variant = manifest.get(_platform_key, {})
	if version.is_empty() or not (platform_data is Dictionary):
		_set_status("Update manifest is incomplete")
		return
	if not platform_data.has("url") or not platform_data.has("sha256"):
		_set_status("Update package details missing")
		return
	var url := str(platform_data.get("url", ""))
	var checksum := str(platform_data.get("sha256", "")).to_lower()
	var expected_prefix := TRUSTED_RELEASE_PREFIX + "v" + version + "/"
	if int(manifest.get("schema_version", 0)) != 1 or not url.begins_with(expected_prefix) or not _is_sha256(checksum):
		_set_status("Update source failed validation")
		return
	_manifest = manifest
	_latest_version = version
	_update_available = _version_is_newer(version, _current_version)
	if _update_available:
		_button.text = "UPDATE " + version
		_set_status("Update available: " + version)
	else:
		_button.text = "CHECK UPDATE"
		_set_status("Game is up to date")

func _download_update() -> void:
	if _mode != "idle" or not _update_available:
		return
	var platform_data: Dictionary = _manifest.get(_platform_key, {})
	var extension := "apk" if _platform_key == "android" else "zip"
	var filename := "NEON_3D_BATTLE_ROYALE." + extension
	var folder := "user://updates"
	var absolute_folder := ProjectSettings.globalize_path(folder)
	var dir_err := DirAccess.make_dir_recursive_absolute(absolute_folder)
	if dir_err != OK and dir_err != ERR_ALREADY_EXISTS:
		_set_status("Cannot create update folder")
		return
	_download_path = folder.path_join(filename)
	_http.download_file = ProjectSettings.globalize_path(_download_path)
	_mode = "download"
	_button.disabled = true
	_button.text = "DOWNLOADING…"
	_set_status("Downloading update…")
	var err := _http.request(str(platform_data.get("url", "")), PackedStringArray(["Accept: application/octet-stream"]), HTTPClient.METHOD_GET)
	if err != OK:
		_mode = "idle"
		_http.download_file = ""
		_button.disabled = false
		_button.text = "RETRY UPDATE"
		_set_status("Download could not start")

func _handle_download_response(result: int, response_code: int) -> void:
	_mode = "idle"
	_http.download_file = ""
	_button.disabled = false
	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		DirAccess.remove_absolute(ProjectSettings.globalize_path(_download_path))
		_set_status("Download failed — retry")
		_button.text = "RETRY UPDATE"
		return
	var platform_data: Dictionary = _manifest.get(_platform_key, {})
	var expected_hash := str(platform_data.get("sha256", "")).to_lower()
	var actual_hash := FileAccess.get_sha256(ProjectSettings.globalize_path(_download_path)).to_lower()
	if actual_hash.is_empty() or actual_hash != expected_hash:
		DirAccess.remove_absolute(ProjectSettings.globalize_path(_download_path))
		_set_status("Update verification failed; file deleted")
		_button.text = "RETRY UPDATE"
		return
	_set_status("Download verified")
	if _platform_key == "android":
		_install_android_apk()
	else:
		_start_windows_update()

func _install_android_apk() -> void:
	if not Engine.has_singleton(PLUGIN_NAME):
		_set_status("Installer component missing; this build cannot install updates")
		_button.text = "CHECK UPDATE"
		return
	var plugin: Object = Engine.get_singleton(PLUGIN_NAME)
	var accepted: bool = bool(plugin.installApk(ProjectSettings.globalize_path(_download_path)))
	if accepted:
		_set_status("Android installer opened — confirm installation")
	else:
		_set_status("Allow app installs in Android settings, then tap UPDATE again")
	_button.text = "CHECK UPDATE"

func _start_windows_update() -> void:
	var helper_source := "res://scripts/windows_update_helper.ps1"
	var helper_text := FileAccess.get_file_as_string(helper_source)
	if helper_text.is_empty():
		_set_status("Windows update helper missing")
		return
	var helper_path := ProjectSettings.globalize_path("user://updates/windows_update_helper.ps1")
	var file := FileAccess.open("user://updates/windows_update_helper.ps1", FileAccess.WRITE)
	if file == null:
		_set_status("Cannot prepare Windows updater")
		return
	file.store_string(helper_text)
	file.close()
	var exe_path := OS.get_executable_path()
	var target_dir := exe_path.get_base_dir()
	var args := PackedStringArray([
		"-NoProfile", "-ExecutionPolicy", "Bypass", "-File", helper_path,
		"-ArchivePath", ProjectSettings.globalize_path(_download_path),
		"-TargetDirectory", target_dir,
		"-ExecutableName", exe_path.get_file(),
		"-ProcessId", str(OS.get_process_id())
	])
	var pid := OS.create_process("powershell.exe", args, false)
	if pid <= 0:
		_set_status("Could not start Windows updater")
		return
	_set_status("Closing game to apply update…")
	get_tree().quit()

func _version_is_newer(candidate: String, current: String) -> bool:
	var a := _version_parts(candidate)
	var b := _version_parts(current)
	for i in range(3):
		if a[i] > b[i]:
			return true
		if a[i] < b[i]:
			return false
	return false

func _version_parts(value: String) -> Array[int]:
	var clean := value.trim_prefix("v").split("-")[0]
	var parts := clean.split(".")
	var output: Array[int] = [0, 0, 0]
	for i in range(mini(parts.size(), 3)):
		output[i] = int(parts[i])
	return output

func _is_sha256(value: String) -> bool:
	if value.length() != 64:
		return false
	for character in value:
		if not ("0123456789abcdef".contains(character)):
			return false
	return true

func _set_status(message: String) -> void:
	if is_instance_valid(_status):
		_status.text = message
	status_changed.emit(message)
