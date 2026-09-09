extends RefCounted
## Only settings applied by this baseline are exposed; no speculative LOD knobs.
const PROFILES := {
	"LOW": {"scale": 0.75, "msaa": Viewport.MSAA_DISABLED, "shadows": false, "far": 260.0},
	"MEDIUM": {"scale": 0.85, "msaa": Viewport.MSAA_2X, "shadows": true, "far": 250.0},
	"HIGH": {"scale": 1.0, "msaa": Viewport.MSAA_4X, "shadows": true, "far": 400.0},
	"ULTRA": {"scale": 1.0, "msaa": Viewport.MSAA_8X, "shadows": true, "far": 600.0},
	"MOBILE": {"scale": 0.75, "msaa": Viewport.MSAA_DISABLED, "shadows": false, "far": 260.0},
}

static func apply(profile: String, viewport: Viewport, camera: Camera3D, sun: DirectionalLight3D) -> bool:
	if not PROFILES.has(profile):
		return false
	var settings: Dictionary = PROFILES[profile]
	viewport.scaling_3d_scale = settings.scale
	viewport.msaa_3d = settings.msaa
	camera.far = settings.far
	sun.shadow_enabled = settings.shadows
	return true
