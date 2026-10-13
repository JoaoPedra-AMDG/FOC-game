"""Write public Supabase settings for the static leaderboard editor."""

import json
import os
import pathlib
import sys


def main() -> None:
    if len(sys.argv) != 2:
        raise SystemExit("Usage: build_admin_config.py OUTPUT_PATH")
    url = os.environ.get("SUPABASE_URL", "").strip()
    key = os.environ.get("SUPABASE_PUBLISHABLE_KEY", "").strip()
    if not url or not key:
        raise SystemExit("SUPABASE_URL and SUPABASE_PUBLISHABLE_KEY are required")
    output = pathlib.Path(sys.argv[1])
    output.parent.mkdir(parents=True, exist_ok=True)
    config = {"url": url, "publishableKey": key}
    output.write_text(
        "window.FOC_ADMIN_CONFIG = " + json.dumps(config) + ";\n",
        encoding="utf-8",
    )


if __name__ == "__main__":
    main()
