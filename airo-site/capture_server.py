import http.server, socketserver, urllib.parse, os
OUT = r"C:\WPAI\Software\StudioOps\airo-site\pages_raw"
os.makedirs(OUT, exist_ok=True)
class H(http.server.BaseHTTPRequestHandler):
    def _cors(self):
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "POST, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "*")
    def do_OPTIONS(self):
        self.send_response(204); self._cors(); self.end_headers()
    def do_POST(self):
        q = urllib.parse.urlparse(self.path).query
        page = urllib.parse.parse_qs(q).get("page", ["page"])[0]
        page = "".join(c for c in page if c.isalnum() or c in "-_") or "page"
        n = int(self.headers.get("Content-Length", 0))
        data = self.rfile.read(n)
        with open(os.path.join(OUT, page + ".html"), "wb") as f:
            f.write(data)
        self.send_response(200); self._cors(); self.end_headers(); self.wfile.write(b"ok")
        print("SAVED", page, n, "bytes", flush=True)
    def log_message(self, *a): pass
socketserver.TCPServer.allow_reuse_address = True
with socketserver.TCPServer(("127.0.0.1", 8791), H) as s:
    print("capture server on 8791", flush=True); s.serve_forever()
