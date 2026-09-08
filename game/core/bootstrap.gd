extends Node3D

const QualityProfiles = preload("res://core/quality_profiles.gd")
var quality_profile := "HIGH"

func _ready() -> void:
	quality_profile = str(ProjectSettings.get_setting("forestin/quality/default", "HIGH"))
	if OS.has_feature("mobile"):
		quality_profile = "MOBILE"
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--quality="):
			quality_profile = argument.trim_prefix("--quality=").to_upper()
	if not QualityProfiles.apply(quality_profile, get_viewport(), $Camera3D, $Sun):
		push_error("Unknown quality profile: " + quality_profile)
		get_tree().quit(2)
		return
	$UI/Panel/Margin/VBox/Status.text = "FASE 0 · INFRAESTRUCTURA NATIVA\nPerfil: %s · Godot %s\nEscena de diagnóstico; personaje y aventura pendientes." % [quality_profile, Engine.get_version_info().string]
	print("FORESTIN_BOOT_OK profile=%s engine=%s" % [quality_profile, Engine.get_version_info().string])
