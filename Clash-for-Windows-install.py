#!/usr/bin/python3

import requests
from tabulate import tabulate

PAGE_SIZE = 5

def get_data(page_number=1):
    release_api = "https://api.github.com/repos/Fndroid/clash_for_windows_pkg/releases"
    params = {"per_page": PAGE_SIZE, "page": page_number}
    r = requests.get(release_api, params)
    return r.json()

def  print_table(data):
    headers = ["No", "Version"]
    version_data = [(i, e['name']) for i,e in enumerate(data)]
    print(tabulate(version_data, headers=headers, tablefmt="pretty"))

def download(data, index):
    
    pass

print_table(get_data())