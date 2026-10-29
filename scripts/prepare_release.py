#!/usr/bin/env python3
"""Create a release manifest from the exact built assets and their SHA-256 hashes."""
import argparse
import hashlib
import json
import os
from pathlib import Path

OWNER = "indianequipments092-commits"
REPO = "NEO-GAME-"

def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()

def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--version", required=True)
    parser.add_argument("--android", required=True, type=Path)
    parser.add_argument("--windows", required=True, type=Path)
    parser.add_argument("--output", required=True, type=Path)
    args = parser.parse_args()
    version = args.version.removeprefix("v")
    if not args.android.is_file() or not args.windows.is_file():
        raise SystemExit("Both Android APK and Windows ZIP must exist before making a manifest.")
    base = f"https://github.com/{OWNER}/{REPO}/releases/download/v{version}"
    manifest = {
        "schema_version": 1,
        "version": version,
        "notes": "NEON 3D BATTLE ROYALE update",
        "android": {
            "url": f"{base}/NEON_3D_BATTLE_ROYALE.apk",
            "sha256": sha256(args.android),
        },
        "windows": {
            "url": f"{base}/NEON_3D_BATTLE_ROYALE_Windows.zip",
            "sha256": sha256(args.windows),
        },
    }
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(manifest, indent=2))

if __name__ == "__main__":
    main()
