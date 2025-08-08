#!/usr/bin/env python3
import subprocess
import shlex
from typing import List, Dict

def run_cmd(cmd):
    try:
        proc = subprocess.run(shlex.split(cmd), capture_output=True, text=True, timeout=20)
        return proc.stdout
    except Exception:
        return ""

def scan_with_nmcli(interface="wlan0") -> List[Dict]:
    out = run_cmd(f"nmcli -t -f SSID,SECURITY,SIGNAL,BSSID,CHAN dev wifi")
    results = []
    if out:
        for l in out.splitlines():
            parts = l.split(':')
            if len(parts) >= 5:
                ssid = ":".join(parts[:-4]) if len(parts) > 5 else parts[0]
                security = parts[-4]
                signal = parts[-3]
                bssid = parts[-2]
                chan = parts[-1]
                results.append({
                    "ssid": ssid.strip(),
                    "security": security.strip(),
                    "signal": int(signal) if signal.isdigit() else None,
                    "bssid": bssid.strip(),
                    "channel": chan.strip()
                })
    return results

def scan_with_iwlist(interface="wlan0") -> List[Dict]:
    out = run_cmd(f"sudo iwlist {interface} scan")
    networks = []
    if not out:
        return networks
    cur = {}
    for line in out.splitlines():
        l = line.strip()
        if l.startswith("Cell"):
            if cur:
                networks.append(cur)
            cur = {}
        elif "ESSID:" in l:
            cur["ssid"] = l.split("ESSID:")[1].strip().strip('"')
        elif "Quality=" in l and "Signal level=" in l:
            try:
                sig_dbm = l.split("Signal level=")[1].split()[0]
                cur["signal_dbm"] = sig_dbm
            except:
                pass
        elif "Encryption key:" in l:
            cur["encryption"] = l.split("Encryption key:")[1].strip()
    if cur:
        networks.append(cur)
    return networks

def scan(interface="wlan0") -> List[Dict]:
    nm = scan_with_nmcli(interface)
    if nm:
        return nm
    return scan_with_iwlist(interface)
