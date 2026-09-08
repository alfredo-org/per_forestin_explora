import importlib.util
from pathlib import Path
import sys
import tempfile
import unittest
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location('native', ROOT / 'tools/native.py')
native = importlib.util.module_from_spec(spec)
spec.loader.exec_module(native)


class CommandGateTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.patch = patch.object(native, 'REPORTS', Path(self.temp.name))
        self.patch.start()

    def tearDown(self):
        self.patch.stop()
        self.temp.cleanup()

    def test_zero_exit_with_engine_error_still_fails(self):
        with self.assertRaises(RuntimeError):
            native.run_checked([sys.executable, '-c', "print('SCRIPT ERROR: broken scene')"], 'error')
        self.assertIn('broken scene', (native.REPORTS / 'error.log').read_text())

    def test_colored_engine_error_fails(self):
        with self.assertRaises(RuntimeError):
            native.run_checked([sys.executable, '-c', "print('\\x1b[31mERROR: broken scene\\x1b[0m')"], 'colored-error')

    def test_nonzero_exit_fails(self):
        with self.assertRaises(RuntimeError):
            native.run_checked([sys.executable, '-c', 'raise SystemExit(2)'], 'failed')

    def test_success_and_spaces_in_arguments(self):
        result = native.run_checked([sys.executable, '-c', 'import sys; print(sys.argv[1])', 'path with spaces'], 'ok')
        self.assertEqual(result.strip(), 'path with spaces')

    def test_timeout_does_not_count_as_success(self):
        import subprocess
        with self.assertRaises(subprocess.TimeoutExpired):
            native.run_checked([sys.executable, '-c', 'import time; time.sleep(2)'], 'timeout', timeout=0.05)


if __name__ == '__main__':
    unittest.main()
