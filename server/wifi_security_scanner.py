#!/usr/bin/env python3
# wifi_security_scanner.py
# Пассивный сканер: запускает airodump-ng на указанном интерфейсе, парсит CSV,
# помечает потенциально уязвимые сети (OPEN/WEP/WPS) и сохраняет JSON-отчёт.

import subprocess
import time
import os
import json
import shutil
from datetime import datetime

TMP_PREFIX = "/tmp/piscan"
CSV_FILE = TMP_PREFIX + "-01.csv"
OUT_JSON = "wifi_security_report.json"

def check_tool(name):
    return shutil.which(name) is not None

def run_airodump(interface: str, timeout: int = 12):
    """
    Запускает airodump-ng и пишет CSV в /tmp/piscan-01.csv.
    Работает пассивно — не выполняет атак.
    """
    # remove old files if exist
    for ext in ["-01.csv", "-01.kismet.csv", "-01.kismet.netxml"]:
        p = TMP_PREFIX + ext
        try:
            if os.path.exists(p):
                os.remove(p)
        except Exception:
            pass

    cmd = ["sudo", "airodump-ng", "--output-format", "csv", "--write", TMP_PREFIX, interface]
    # Запускаем как subprocess и убиваем через timeout
    proc = subprocess.Popen(cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    try:
        time.sleep(timeout)
    finally:
        proc.terminate()
        # небольшая пауза, чтобы файл дописался
        time.sleep(1)

def parse_airodump_csv(path: str):
    """
    Парсит CSV, возвращает список AP (dict).
    Формат: airodump-ng CSV содержит сразу секцию AP и секцию клиентов; мы читаем первую секцию.
    """
    if not os.path.exists(path):
        return {"error": "CSV not found", "path": path}

    with open(path, "r", encoding="utf-8", errors="ignore") as f:
        lines = [l.rstrip("\n") for l in f]

    # Найдём раздел AP (до пустой строки), игнорируем заголовок клиента
    ap_lines = []
    in_ap = True
    for line in lines:
        if line.strip() == "":
            # пустая строка — раздел между AP и stations
            if ap_lines:
                # stop on first blank after AP header block
                break
            else:
                continue
        ap_lines.append(line)

    # первые строки — заголовки и разделитель, нужно пропустить заголовок колонки
    # airodump CSV: первая линия часто — header с полями "BSSID, First time seen, Last time seen, channel, speed, privacy, cipher, authentication, power, # beacons, # IV, LAN IP, ID-length, ESSID, Key"
    # Найдём индекс строки с "BSSID" и начнём с неё+1
    start_idx = 0
    for i, l in enumerate(ap_lines):
        if "BSSID" in l and "ESSID" in l:
            start_idx = i + 1
            break

    entries = []
    for l in ap_lines[start_idx:]:
        if not l.strip():
            break
        parts = [p.strip() for p in l.split(",")]
        # airodump's CSV columns sometimes vary — guard with try
        try:
            bssid = parts[0]
            channel = parts[3] if len(parts) > 3 else None
            privacy = parts[5] if len(parts) > 5 else None   # "Privacy" (WEP/WPA/etc)
            cipher = parts[6] if len(parts) > 6 else None
            auth = parts[7] if len(parts) > 7 else None
            power = parts[8] if len(parts) > 8 else None     # dBm
            beacons = parts[9] if len(parts) > 9 else None
            # ESSID usually at near end, but can contain commas; join rest
            ssid = None
            if len(parts) >= 14:
                ssid = ",".join(parts[13:]).strip()
            else:
                ssid = parts[-1] if parts else ""
            # Normalize
            ssid = ssid.strip().strip('"')
            entry = {
                "bssid": bssid,
                "ssid": ssid if ssid else "<hidden>",
                "channel": channel,
                "privacy": privacy,
                "cipher": cipher,
                "auth": auth,
                "power_dbm": power,
                "beacons": beacons
            }
            entries.append(entry)
        except Exception:
            # пропускаем строку, если парсинг неожиданного формата
            continue
    return entries

def analyze_entries(entries):
    """
    Помечаем потенциальные проблемы:
      - OPEN  (no encryption)
      - WEP   (legacy)
      - WPS   (airodump-ng иногда отмечает 'WPS' в поле 'auth'/'cipher' или в ESSID column)
    """
    analyzed = []
    for e in entries:
        issues = []
        p = (e.get("privacy") or "").upper()
        c = (e.get("cipher") or "").upper()
        a = (e.get("auth") or "").upper()
        ssid = e.get("ssid","")
        # Open network
        if p in ("--", "", "NONE") or "OPN" in p or "OPEN" in p:
            issues.append("OPEN (no encryption)")
        # WEP
        if "WEP" in p or "WEP" in c:
            issues.append("WEP (legacy encryption)")
        # WPA vs WPA2 vs WPA3 heuristics
        if "WPA" in p and "WPA2" not in p and "WPA3" not in p:
            issues.append("WPA (legacy) — consider WPA2/WPA3")
        # WPS detection (heuristic)
        # airodump sometimes marks WPS in the 'cipher'/'auth' or has 'WPS' substring
        if "WPS" in p or "WPS" in c or "WPS" in a or ("WPS" in ssid.upper()):
            issues.append("WPS enabled (check router config)")
        # weak signal (threshold -80 dBm)
        try:
            power = int(e.get("power_dbm") or -999)
            if power != -999 and power < -80:
                issues.append(f"Weak RSSI ({power} dBm)")
        except:
            pass

        recs = []
        if "OPEN (no encryption)" in issues:
            recs.append("Enable WPA2/3 with strong password or configure guest network with isolation.")
        if "WEP (legacy encryption)" in issues:
            recs.append("Replace WEP with WPA2/WPA3 immediately.")
        if any("WPS" in s for s in issues):
            recs.append("Disable WPS in router settings (WPS compromises security).")
        if any("Weak RSSI" in s for s in issues):
            recs.append("Improve placement / increase AP power or add extenders.")
        if not recs:
            recs.append("No obvious config issues detected — further testing only with explicit permission.")

        analyzed.append({
            **e,
            "issues": issues,
            "recommendations": recs
        })
    return analyzed

def save_report(report):
    with open(OUT_JSON, "w", encoding="utf-8") as f:
        json.dump(report, f, ensure_ascii=False, indent=2)

def main():
    import argparse
    parser = argparse.ArgumentParser(description="Passive Wi-Fi security scanner (safe, non-destructive).")
    parser.add_argument("--iface", required=True, help="monitor-mode interface (e.g. wlan0mon)")
    parser.add_argument("--time", type=int, default=12, help="scan duration in seconds")
    args = parser.parse_args()

    if not check_tool("airodump-ng"):
        print("[!] 'airodump-ng' not found. Install aircrack-ng package.")
        return

    print(f"[+] Starting passive scan on {args.iface} for {args.time}s (airodump-ng)...")
    run_airodump(args.iface, timeout=args.time)
    print("[+] Parsing CSV...")
    entries = parse_airodump_csv(CSV_FILE)
    if isinstance(entries, dict) and entries.get("error"):
        print("[!] CSV parsing error:", entries)
        return
    print(f"[+] Found {len(entries)} AP entries (raw). Analyzing...")
    analyzed = analyze_entries(entries)
    report = {
        "scanned_at": datetime.utcnow().isoformat() + "Z",
        "interface": args.iface,
        "duration_s": args.time,
        "results": analyzed
    }
    save_report(report)
    print(f"[+] Report saved to {OUT_JSON}")
    # pretty-print top results
    for r in analyzed:
        print(f"- {r['ssid']} ({r['bssid']}) [{r.get('power_dbm')}] issues: {r['issues']}")

if __name__ == "__main__":
    main()
