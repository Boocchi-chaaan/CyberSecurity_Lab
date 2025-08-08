#!/usr/bin/env python3
from flask import Flask, jsonify, render_template_string
import json
import os

LOG_FILE = "wifi_log.json"

app = Flask(__name__)

HTML_PAGE = """
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>PiCyber Wi-Fi Monitor</title>
    <style>
        body { font-family: Arial; background: #1e1e1e; color: white; padding: 20px; }
        table { width: 100%; border-collapse: collapse; margin-top: 20px; }
        th, td { padding: 8px; border: 1px solid #555; text-align: left; }
        th { background: #333; }
        tr:nth-child(even) { background: #2a2a2a; }
    </style>
</head>
<body>
<h1>📡 PiCyber Wi-Fi Monitor</h1>
<p>Последние обнаруженные сети</p>
<table>
<tr><th>SSID</th><th>Security</th><th>Signal</th><th>BSSID</th><th>Channel</th></tr>
{% for net in networks %}
<tr>
<td>{{ net.get('ssid', 'unknown') }}</td>
<td>{{ net.get('security', '-') }}</td>
<td>{{ net.get('signal', net.get('signal_dbm', '-')) }}</td>
<td>{{ net.get('bssid', '-') }}</td>
<td>{{ net.get('channel', '-') }}</td>
</tr>
{% endfor %}
</table>
</body>
</html>
"""

@app.route("/")
def home():
    if not os.path.exists(LOG_FILE):
        return "Нет данных, запусти scanner_loop.py"
    with open(LOG_FILE, "r", encoding="utf-8") as f:
        lines = f.readlines()
    if not lines:
        return "Нет данных"
    last_entry = json.loads(lines[-1])
    return render_template_string(HTML_PAGE, networks=last_entry["networks"])

@app.route("/api")
def api_data():
    if not os.path.exists(LOG_FILE):
        return jsonify({"error": "no data"})
    with open(LOG_FILE, "r", encoding="utf-8") as f:
        lines = f.readlines()
    if not lines:
        return jsonify({"error": "no data"})
    last_entry = json.loads(lines[-1])
    return jsonify(last_entry)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
