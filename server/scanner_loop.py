#!/usr/bin/env python3
import json
import time
from datetime import datetime
from wifi_scanner import scan

INTERFACE = "wlan0"
INTERVAL = 30
LOG_FILE = "wifi_log.json"

def loop_scan():
    print(f"[+] Starting Wi-Fi scan loop on {INTERFACE} every {INTERVAL}s...")
    while True:
        try:
            results = scan(INTERFACE)
            timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            entry = {"time": timestamp, "networks": results}
            
            # Лог в файл
            with open(LOG_FILE, "a", encoding="utf-8") as f:
                f.write(json.dumps(entry, ensure_ascii=False) + "\n")
            
            print(f"[{timestamp}] Found {len(results)} networks.")
            time.sleep(INTERVAL)

        except KeyboardInterrupt:
            print("\n[!] Stopped by user.")
            break
        except Exception as e:
            print(f"[!] Error: {e}")
            time.sleep(INTERVAL)

if __name__ == "__main__":
    loop_scan()
