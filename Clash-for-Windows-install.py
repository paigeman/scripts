#!/usr/bin/python3

import requests
from tabulate import tabulate
from tqdm import tqdm
import tarfile
import os
import re

DOWNLOAD_DIR = "/root/下载/"

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

def get_file_version(data, index):
    return data[index]['name']

def replace_template_path(content: str, path):
    if content.startswith("Exec"):
        tokens = content.split("=")
        tokens[2] = path + " --no-sandbox"
        return str.join(" ", tokens)
    return content

def replace_template_version(content: str, version):
    if content.startswith("Version"):
        tokens = content.split("=")
        tokens[2] = version
        return str.join(" ", tokens)
    return content

def download(data, index):
    """
    for my os
    """
    url = data[index]['assets'][7]['browser_download_url']
    path = DOWNLOAD_DIR+ get_file_name(data, index)
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
install_directory = "/opt/Clash-for-Windows/"
data = get_data(page_number)
print_table(data)
"""
as github does not provide the total of datum, 
it is impossible to calculate how many pages do the api provide
"""
op = input("which version do you want to download(input 0 to 4, q to quit):")
if op == "q":
    SystemExit()
else:
    download(data, int(op))
    re_directory_name = ""
    with tarfile.open(DOWNLOAD_DIR + get_file_name(data, int(op))) as tmp:
        tmp.extractall(install_directory)
        directory_name = tmp.getnames()[0]
        re_directory_name = re.sub(" ", "-", directory_name)
    os.rename(install_directory + directory_name, install_directory + re_directory_name)
    with open("/usr/share/applications/Clash-for-Windows.desktop", "w") as file:
        pass