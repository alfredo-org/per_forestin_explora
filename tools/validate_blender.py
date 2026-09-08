"""Run a real Blender -> GLB -> Godot pipeline gate without changing source assets."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile

from native import ROOT, REPORTS, godot_path, run_checked


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--blender', default=os.environ.get('BLENDER_BIN') or shutil.which('blender'))
    parser.add_argument('--godot')
    args = parser.parse_args()
    report = {'status': 'failed', 'artistic_review': 'not performed', 'fixture': '2 meter cube with material'}
    REPORTS.mkdir(parents=True, exist_ok=True)
    try:
        executable = godot_path(args.godot)
        if not args.blender or not executable:
            raise RuntimeError('Both Blender 4.5.x and Godot are required; set BLENDER_BIN/GODOT_BIN or pass flags.')
        with tempfile.TemporaryDirectory(prefix='blender-fixture-', dir=ROOT / 'builds') as temporary:
            source = Path(temporary) / 'source.blend'
            target = Path(temporary) / 'fixture.glb'
            run_checked([args.blender, '--background', '--factory-startup', '--python-exit-code', '1',
                         '--python', str(ROOT / 'tests/blender_fixture.py'), '--', str(source)], 'blender-fixture')
            original = hashlib.sha256(source.read_bytes()).hexdigest()
            run_checked([args.blender, '--background', str(source), '--python-exit-code', '1',
                         '--python', str(ROOT / 'blender/scripts/export_glb.py'), '--', str(target),
                         '--collection', 'ExportFixture'], 'blender-export')
            if hashlib.sha256(source.read_bytes()).hexdigest() != original:
                raise RuntimeError('Exporter modified the .blend source')
            report['source_sha256_preserved'] = original
            output = run_checked([executable, '--headless', '--path', str(ROOT / 'game'), '--script',
                                  'res://tests/glb_test.gd', '--', str(target)], 'glb-import')
            if 'FORESTIN_GLB_RESULT failures=0' not in output:
                raise RuntimeError('GLB test did not report success')
            report['glb_bytes'] = target.stat().st_size
            report['glb_sha256'] = hashlib.sha256(target.read_bytes()).hexdigest()
        report['status'] = 'passed'
        return 0
    except (OSError, RuntimeError, subprocess.SubprocessError) as exc:
        report['error'] = str(exc)
        print('BLENDER PIPELINE FAILED:', exc, file=sys.stderr)
        return 1
    finally:
        (REPORTS / 'blender-result.json').write_text(json.dumps(report, indent=2) + '\n')


if __name__ == '__main__':
    sys.exit(main())
