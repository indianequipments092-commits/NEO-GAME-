import hashlib
import json
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

SCRIPT = Path(__file__).resolve().parents[1] / "scripts" / "prepare_release.py"

class ReleaseManifestTests(unittest.TestCase):
    def test_manifest_contains_matching_hashes_and_trusted_urls(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            apk = root / "game.apk"
            windows = root / "game.zip"
            output = root / "update-manifest.json"
            apk.write_bytes(b"test-apk-bytes")
            windows.write_bytes(b"test-windows-zip")
            subprocess.run([
                sys.executable, str(SCRIPT), "--version", "v1.2.3",
                "--android", str(apk), "--windows", str(windows),
                "--output", str(output)
            ], check=True, capture_output=True, text=True)
            manifest = json.loads(output.read_text(encoding="utf-8"))
            self.assertEqual(manifest["version"], "1.2.3")
            self.assertEqual(manifest["android"]["sha256"], hashlib.sha256(apk.read_bytes()).hexdigest())
            self.assertEqual(manifest["windows"]["sha256"], hashlib.sha256(windows.read_bytes()).hexdigest())
            self.assertTrue(manifest["android"]["url"].startswith("https://github.com/indianequipments092-commits/NEO-GAME-/releases/download/v1.2.3/"))
            self.assertTrue(manifest["windows"]["url"].endswith("NEON_3D_BATTLE_ROYALE_Windows.zip"))

    def test_missing_asset_fails(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            apk = root / "missing.apk"
            windows = root / "game.zip"
            windows.write_bytes(b"zip")
            result = subprocess.run([
                sys.executable, str(SCRIPT), "--version", "1.0.0",
                "--android", str(apk), "--windows", str(windows),
                "--output", str(root / "manifest.json")
            ], capture_output=True, text=True)
            self.assertNotEqual(result.returncode, 0)

if __name__ == "__main__":
    unittest.main()
