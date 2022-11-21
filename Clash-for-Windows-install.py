#!/usr/bin/python3

import requests
from tabulate import tabulate
from tqdm import tqdm

def get_data(page_number=1):
    page_size = 5
    release_api = "https://api.github.com/repos/Fndroid/clash_for_windows_pkg/releases"
    params = {"per_page": page_size, "page": page_number}
    r = requests.get(release_api, params)
    return r.json()

def  print_table(data):
    headers = ["No", "Version"]
    version_data = [(i, e['name']) for i,e in enumerate(data)]
    print(tabulate(version_data, headers=headers, tablefmt="pretty"))

def get_file_name(data, index):
    return data[index]['assets'][7]['name']

def download(data, index):
    """
    for my os
    """
    url = data[index]['assets'][7]['browser_download_url']
    path = "/root/下载/" + get_file_name(data, index)
    resp = requests.get(url, stream=True)
    total = int(resp.headers.get('content-length', 0))
    with open(path, "wb") as file, tqdm(
        desc=path,
        total=total,
        unit='iB',
        unit_scale=True,
        unit_divisor=1024
    ) as bar:
        for data in resp.iter_content(chunk_size=1024):
            size = file.write(data)
            bar.update(size)

page_number = 1
data = get_data(page_number)
print_table(data)
index = input("which version do you want to download(input 0 to 4):")
