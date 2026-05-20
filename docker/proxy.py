import json
from http.server import BaseHTTPRequestHandler, HTTPServer
from urllib import request as urllib_request, parse

import os
LT_URL = os.environ.get("LT_INTERNAL_URL", "http://host.docker.internal:8082")

class Proxy(BaseHTTPRequestHandler):
    def log_message(self, format, *args):
        pass

    def send_cors(self):
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "Content-Type, Authorization")

    def do_OPTIONS(self):
        self.send_response(204)
        self.send_cors()
        self.send_header("Access-Control-Max-Age", "86400")
        self.end_headers()

    def do_GET(self):
        req = urllib_request.Request(LT_URL + self.path)
        try:
            res = urllib_request.urlopen(req)
            body = res.read()
            self.send_response(res.status)
            self.send_cors()
            self.send_header("Content-Type", res.headers.get("Content-Type", "application/json"))
            self.end_headers()
            self.wfile.write(body)
        except Exception as e:
            self.send_response(502)
            self.end_headers()

    def do_POST(self):
        length = int(self.headers.get("Content-Length", 0))
        raw = self.rfile.read(length) if length else b""
        ct = self.headers.get("Content-Type", "")

        # Convert JSON → form-encoded
        if "json" in ct:
            try:
                data = json.loads(raw)
                body = parse.urlencode(data).encode()
            except Exception:
                body = raw
        else:
            body = raw

        path = self.path
        # Normalize /check → /v2/check
        if path.startswith("/check"):
            path = "/v2" + path

        req = urllib_request.Request(
            LT_URL + path,
            data=body,
            headers={"Content-Type": "application/x-www-form-urlencoded"},
            method="POST"
        )
        try:
            res = urllib_request.urlopen(req)
            resp_body = res.read()
            self.send_response(res.status)
            self.send_cors()
            self.send_header("Content-Type", res.headers.get("Content-Type", "application/json"))
            self.end_headers()
            self.wfile.write(resp_body)
        except urllib_request.HTTPError as e:
            resp_body = e.read()
            self.send_response(e.code)
            self.send_cors()
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            self.wfile.write(resp_body)

if __name__ == "__main__":
    port = int(os.environ.get("LT_PROXY_PORT", "8080"))
    server = HTTPServer(("0.0.0.0", port), Proxy)
    print(f"Proxy running on :{port} → {LT_URL}")
    server.serve_forever()
