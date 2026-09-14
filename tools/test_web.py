"""Smoke-check the actual exported WebAssembly game in Chromium."""
from pathlib import Path
from functools import partial
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from threading import Thread
from playwright.sync_api import sync_playwright
root = Path(__file__).resolve().parents[1]
report = root / "builds/web-qa"
report.mkdir(parents=True, exist_ok=True)
server = ThreadingHTTPServer(("127.0.0.1", 8765), partial(SimpleHTTPRequestHandler, directory=str(root / "dist")))
Thread(target=server.serve_forever, daemon=True).start()
errors, messages = [], []
try:
    with sync_playwright() as p:
        browser = p.chromium.launch(args=["--enable-webgl", "--use-gl=angle", "--use-angle=swiftshader", "--enable-unsafe-swiftshader"])
        page = browser.new_page(viewport={"width":1280,"height":720})
        page.on("pageerror", lambda e: errors.append(str(e)))
        page.on("console", lambda m: messages.append(m.text))
        page.goto("http://127.0.0.1:8765/aventura/", wait_until="load")
        page.wait_for_function("typeof Engine !== 'undefined'", timeout=60000)
        import time
        deadline = time.monotonic() + 120
        while not any("FORESTIN_ADVENTURE_READY" in m for m in messages):
            if time.monotonic() > deadline:
                raise RuntimeError("Godot scene did not reach ready state")
            page.wait_for_timeout(500)
        page.wait_for_timeout(2000)
        page.locator("canvas").screenshot(path=str(report / "web-title.png"))
        if errors or any("SCRIPT ERROR:" in m for m in messages):
            raise RuntimeError(str(errors) + "\n" + "\n".join(messages))
        print("FORESTIN_WEB_READY: native scene loaded in Chromium/WebGL")
        browser.close()
finally:
    (report / "console.log").write_text("\n".join(messages + errors))
    server.shutdown()
