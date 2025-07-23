#!/usr/bin/env python3
"""
Minimal, robust JSON API wrapper for apcupsd.
Serves UPS status at /ups/status
"""

from flask import Flask, jsonify
import subprocess
import time
import threading

# --- settings ---
APC_HOST = "127.0.0.1:3551"   
APC_TIMEOUT = 10              
CACHE_TTL = 10                
STALE_MAX = 60                
LISTEN_HOST = "0.0.0.0"
LISTEN_PORT = 8888
# ------------------

app = Flask(__name__)

_cache_data = {}
_cache_ts = 0.0
_cache_lock = threading.Lock()


def _run_apcaccess():
    try:
        out = subprocess.check_output(
            ["apcaccess", "-h", APC_HOST],
            text=True,
            timeout=APC_TIMEOUT,
        )
    except Exception as e:  # noqa
        return {"error": f"apcaccess failed: {e}"}

    data = {}
    for line in out.splitlines():
        if ":" not in line:
            continue
        k, v = line.split(":", 1)
        data[k.strip()] = v.strip()
    return data


def _refresh_cache():
    global _cache_data, _cache_ts
    data = _run_apcaccess()
    ts = time.time()
    with _cache_lock:
        _cache_data = data
        _cache_ts = ts


def get_status():
    now = time.time()
    with _cache_lock:
        age = now - _cache_ts
        if _cache_data and age < CACHE_TTL:
            data = dict(_cache_data)  # copy
            data_age = age
        else:
            data = None
            data_age = None

    if data is None:
        _refresh_cache()
        with _cache_lock:
            data = dict(_cache_data)
            data_age = now - _cache_ts

    if data_age is not None and data_age > STALE_MAX:
        data = dict(data)
        data["stale"] = True
        data["stale_age_seconds"] = int(data_age)

    return data

@app.route("/ups/status", methods=["GET"])
def ups_status():
    return jsonify(get_status())


if __name__ == "__main__":
    app.run(host=LISTEN_HOST, port=LISTEN_PORT)
