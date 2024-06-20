#!/usr/bin/python3

import login
import logging
import re
import os

logging.basicConfig(level=logging.INFO ,format="%(asctime)s %(filename)s %(funcName)s：line %(lineno)d %(levelname)s %(message)s")

class Sign:
    def __init__(self, hostname, username, password, questionid='0', answer=None, cookies_flag=True):
        self.hostname = hostname
        self.discuz_login = login.Login(self.hostname, username, password, questionid, answer, cookies_flag)
    
    def login(self):
        self.discuz_login.main()
        self.session = self.discuz_login.session

    def sign(self):
        # 未来可以考虑直接用formhash拼接，目测是同一个formhash
        rst = self.session.get(f'https://{self.hostname}/plugin.php?id=zqlj_sign').text
        # logging.info(rst)
        sign = re.search(r'a href="plugin.php\?id=zqlj_sign&sign=(.+?)".+?>.+?打卡</a>', rst).group(1)
        rst = self.session.get(f'https://{self.hostname}/plugin.php?id=zqlj_sign&sign={sign}').text
        # logging.info(rst)
        if '已经打过卡' in rst:
            logging.warning('已经打过卡')
        else:
            logging.info('打卡成功')
    
if __name__ == '__main__':
    hostname = 'jietiandi.net'
    username = os.getenv('USERNAME')
    password = os.getenv('PASSWORD')
    sign = Sign(hostname,username,password)
    sign.login()
    sign.sign()