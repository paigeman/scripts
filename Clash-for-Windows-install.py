#!/usr/bin/python3

import json
import requests
from tabulate import tabulate

REALEASE_API = "https://api.github.com/repos/Fndroid/clash_for_windows_pkg/releases"
PAGE_SIZE = 5

def get_data(page_number=1):
    params = {"per_page": PAGE_SIZE, "page": page_number}
    r = requests.get(REALEASE_API, params)
    return r.json()

