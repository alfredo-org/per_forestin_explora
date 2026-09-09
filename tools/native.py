"""Portable native build driver. Run from any directory; Python standard library only."""
import argparse
from datetime import datetime, timezone
import json
import os
from pathlib import Path
import platform
import re
import shutil
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
CONFIG = json.loads((ROOT / 'tools/toolchain.json').read_text())
REPORTS = ROOT / 'builds/reports'
ERROR_PATTERN = re.compile(r'(^|\n)(?:SCRIPT ERROR:|ERROR:|Parse Error:)', re.MULTILINE)


def godot_path(explicit=None):
    if explicit:
        return str(Path(explicit).expanduser().resolve()) if Path(explicit).exists() else explicit
    if os.environ.get('GODOT_BIN'):
        return os.environ['GODOT_BIN']
    base = ROOT / '.tools' / ('godot-' + CONFIG['godot'])
    candidates = [base / ('Godot_v' + CONFIG['godot_release'] + '_linux.x86_64'),
                  base / ('Godot_v' + CONFIG['godot_release'] + '_win64_console.exe'),
                  base / 'Godot.app/Contents/MacOS/Godot']
    return next((str(p) for p in candidates if p.is_file()), None) or shutil.which('godot') or shutil.which('godot4')


def run_checked(command, name, timeout=240):
    REPORTS.mkdir(parents=True, exist_ok=True)
    result = subprocess.run(command, cwd=ROOT, text=True, stdout=subprocess.PIPE,
                            stderr=subprocess.STDOUT, timeout=timeout, encoding='utf-8', errors='replace')
    (REPORTS / (name + '.log')).write_text(result.stdout, encoding='utf-8')
    print(result.stdout)
    plain_output = re.sub(r'\x1b\[[0-9;]*[A-Za-z]', '', result.stdout)
    if result.returncode != 0 or ERROR_PATTERN.search(plain_output):
        raise RuntimeError(name + ' failed; see builds/reports/' + name + '.log')
    return result.stdout


def version_of(executable):
    result = subprocess.run([executable, '--version'], text=True, capture_output=True, timeout=20, check=True)
    return result.stdout.strip()


def doctor(executable):
    result = {'platform': platform.platform(), 'python': platform.python_version(),
              'godot': None, 'expected_godot': CONFIG['godot'], 'blender': None,
              'xcode': shutil.which('xcodebuild'), 'native_gpu_tested': False}
    if executable:
        try:
            result['godot'] = version_of(executable)
        except (OSError, subprocess.SubprocessError) as exc:
            result['godot_error'] = str(exc)
    blender = os.environ.get('BLENDER_BIN') or shutil.which('blender')
    if blender:
        try:
            result['blender'] = version_of(blender).splitlines()[0]
        except (OSError, subprocess.SubprocessError) as exc:
            result['blender_error'] = str(exc)
    REPORTS.mkdir(parents=True, exist_ok=True)
    (REPORTS / 'doctor.json').write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps(result, indent=2))
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('command', choices=['doctor', 'validate', 'export-windows'])
    parser.add_argument('--godot')
    args = parser.parse_args()
    executable = godot_path(args.godot)
    if args.command == 'doctor':
        doctor(executable)
        return 0
    report = {'time_utc': datetime.now(timezone.utc).isoformat(), 'command': args.command,
              'status': 'failed', 'gpu_review': 'pending', 'iphone_review': 'pending'}
    try:
        if not executable:
            raise RuntimeError('Godot missing. Run python tools/setup_godot.py or set GODOT_BIN.')
        version = version_of(executable)
        report['godot_version'] = version
        if not version.startswith(CONFIG['godot'] + '.stable'):
            raise RuntimeError('Expected Godot ' + CONFIG['godot'] + '.stable; got ' + version)
        run_checked([executable, '--headless', '--path', str(ROOT / 'game'), '--editor', '--import', '--quit'], 'import')
        output = run_checked([executable, '--headless', '--path', str(ROOT / 'game'), '--script', 'res://tests/smoke_test.gd'], 'smoke')
        if 'FORESTIN_SMOKE_RESULT failures=0' not in output:
            raise RuntimeError('Smoke test exited without a passing result marker')
        output = run_checked([executable, '--headless', '--path', str(ROOT / 'game'), '--quit-after', '10', '--', '--no-save'], 'main-scene')
        if 'FORESTIN_ADVENTURE_READY' not in output:
            raise RuntimeError('Configured main scene did not reach adventure')
        output = run_checked([executable, '--headless', '--path', str(ROOT / 'game'), '--script', 'res://tests/adventure_test.gd', '--', '--no-save'], 'adventure')
        if 'FORESTIN_ADVENTURE_RESULT failures=0' not in output:
            raise RuntimeError('Adventure checks did not pass')
        if args.command == 'export-windows':
            target = ROOT / 'builds/windows/ForestinAventura.exe'
            target.parent.mkdir(parents=True, exist_ok=True)
            # Delete prior output so a stale build can never count as this run's success.
            target.unlink(missing_ok=True)
            run_checked([executable, '--headless', '--path', str(ROOT / 'game'), '--export-release',
                         'Windows Desktop', str(target)], 'windows-export', timeout=600)
            if not target.is_file() or target.stat().st_size == 0:
                raise RuntimeError('Export did not produce a Windows executable')
            report['windows_executable_bytes'] = target.stat().st_size
            report['windows_execution'] = 'pending on Windows'
        report['status'] = 'passed'
        return 0
    except (OSError, RuntimeError, subprocess.SubprocessError) as exc:
        report['error'] = str(exc)
        print('NATIVE FAILED:', exc, file=sys.stderr)
        return 1
    finally:
        REPORTS.mkdir(parents=True, exist_ok=True)
        (REPORTS / 'native-result.json').write_text(json.dumps(report, indent=2) + '\n')


if __name__ == '__main__':
    sys.exit(main())
