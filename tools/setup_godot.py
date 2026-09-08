"""Install pinned official Godot into this checkout; optionally Windows templates."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import platform
import shutil
import subprocess
import sys
import zipfile

ROOT = Path(__file__).resolve().parents[1]
CONFIG = json.loads((ROOT / 'tools/toolchain.json').read_text())
CACHE = ROOT / '.tools'


def download(key):
    item = CONFIG['downloads'][key]
    archive = CACHE / item['file']
    CACHE.mkdir(exist_ok=True)
    if archive.exists() and digest(archive) == item['sha256']:
        return archive
    url = 'https://github.com/godotengine/godot/releases/download/' + CONFIG['godot_release'] + '/' + item['file']
    partial = archive.with_suffix(archive.suffix + '.partial')
    # curl is available on supported modern Windows/macOS and CI Linux.
    subprocess.run(['curl', '-fL', '--retry', '2', '--connect-timeout', '30',
                    '--max-time', '900', '-o', str(partial), url], check=True)
    if digest(partial) != item['sha256']:
        raise RuntimeError('Checksum mismatch: ' + item['file'])
    partial.replace(archive)
    return archive


def digest(path):
    h = hashlib.sha256()
    with path.open('rb') as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b''):
            h.update(chunk)
    return h.hexdigest()


def install(templates=False):
    system = platform.system().lower()
    if system not in ('linux', 'windows', 'darwin'):
        raise RuntimeError('Unsupported OS')
    if system != 'darwin' and platform.machine().lower() not in ('x86_64', 'amd64'):
        raise RuntimeError('This bootstrap pins x86_64 on Linux/Windows; select an official ARM build manually.')
    archive = download(system)
    target = CACHE / ('godot-' + CONFIG['godot'])
    with zipfile.ZipFile(archive) as z:
        z.extractall(target)
    if system == 'darwin':
        executable = target / 'Godot.app/Contents/MacOS/Godot'
    elif system == 'windows':
        executable = target / ('Godot_v' + CONFIG['godot_release'] + '_win64_console.exe')
    else:
        executable = target / ('Godot_v' + CONFIG['godot_release'] + '_linux.x86_64')
    executable.chmod(executable.stat().st_mode | 0o111)
    if templates:
        archive = download('templates')
        if system == 'windows':
            data = Path(os.environ['APPDATA'])
        elif system == 'darwin':
            data = Path.home() / 'Library/Application Support'
        else:
            data = Path(os.environ.get('XDG_DATA_HOME', str(Path.home() / '.local/share')))
        destination = data / 'godot/export_templates' / (CONFIG['godot'] + '.stable')
        destination.mkdir(parents=True, exist_ok=True)
        with zipfile.ZipFile(archive) as z:
            for name in ('windows_debug_x86_64.exe', 'windows_release_x86_64.exe', 'version.txt'):
                with z.open('templates/' + name) as source, (destination / name).open('wb') as out:
                    shutil.copyfileobj(source, out)
    subprocess.run([str(executable), '--version'], check=True)
    print('Godot installed:', executable)
    return executable


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--windows-templates', action='store_true', help='Download 1.36 GB archive; install Windows templates only')
    args = parser.parse_args()
    try:
        install(args.windows_templates)
    except (OSError, RuntimeError, subprocess.CalledProcessError, zipfile.BadZipFile) as exc:
        print('SETUP FAILED:', exc, file=sys.stderr)
        sys.exit(1)
