"""Export the native Godot game for browsers using verified official templates."""
from pathlib import Path
import subprocess
import zipfile
import setup_godot

ROOT = Path(__file__).resolve().parents[1]
godot = setup_godot.install()
archive = setup_godot.download("templates")
destination = Path.home() / ".local/share/godot/export_templates" / (setup_godot.CONFIG["godot"] + ".stable")
destination.mkdir(parents=True, exist_ok=True)
with zipfile.ZipFile(archive) as z:
    names = [n for n in z.namelist() if Path(n).name.startswith("web_") or Path(n).name == "version.txt"]
    if not any("nothreads_release" in n for n in names):
        raise RuntimeError("Official single-threaded web template missing")
    for name in names:
        (destination / Path(name).name).write_bytes(z.read(name))
out = ROOT / "dist/aventura"
out.mkdir(parents=True, exist_ok=True)
for args in [
    ["--headless", "--path", str(ROOT / "game"), "--editor", "--import"],
    ["--headless", "--path", str(ROOT / "game"), "--export-release", "Web", str(out / "index.html")],
]:
    result = subprocess.run([str(godot), *args], text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, timeout=240)
    print(result.stdout, flush=True)
    if result.returncode or "SCRIPT ERROR:" in result.stdout or "\nERROR:" in result.stdout:
        raise RuntimeError("Godot import/export failed")
for name in ["index.html", "index.js", "index.wasm", "index.pck"]:
    if not (out / name).is_file() or (out / name).stat().st_size == 0:
        raise RuntimeError("Missing web export: " + name)
(out / "version.json").write_text('{"version":"0.1.2","platform":"web","threads":false}\n')
