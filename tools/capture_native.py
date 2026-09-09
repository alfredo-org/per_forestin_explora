"""Capture the actual Godot renderer; fail on shader/runtime errors, not just exit code."""
import native

executable = native.godot_path()
if not executable:
    raise SystemExit('Godot missing')
output = native.run_checked([
    executable, '--path', str(native.ROOT / 'game'), '--audio-driver', 'Dummy',
    '--script', 'res://tests/capture_adventure.gd', '--', '--no-save',
], 'render-capture', timeout=230)
if 'FORESTIN_CAPTURE_OK' not in output:
    raise SystemExit('Renderer did not finish all captures')
