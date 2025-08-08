#!/usr/bin/env python3
# wifi_scan.py — loop version
import json
import time
from datetime import datetime
from wifi_scan import scan  # импортируем нашу функцию из предыдущего кода

INTERFACE = "wlan0"  # можно поменять на свой
INTERVAL = 30        # задержка между сканами в секундах
LOG_FILE = "wifi_log.json"  # сюда будет сохраняться история

def loop_scan():
    print(f"[+] Starting Wi-Fi scan loop on interface {INTERFACE} (every {INTERVAL}s)...")
    while True:
        try:
            results = scan(INTERFACE)
            timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            print(f"\n--- Scan at {timestamp} ---")
            print(json.dumps(results, ensure_ascii=False, indent=2))

            # Логируем в файл
            with open(LOG_FILE, "a", encoding="utf-8") as f:
                entry = {"time": timestamp, "networks": results}
                f.write(json.dumps(entry, ensure_ascii=False) + "\n")

            time.sleep(INTERVAL)

        except KeyboardInterrupt:
            print("\n[!] Stopped by user")
            break
        except Exception as e:
            print(f"[!] Error: {e}")
            time.sleep(INTERVAL)

if __name__ == "__main__":
    loop_scan()
