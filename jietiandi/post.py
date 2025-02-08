#!/usr/bin/python3

import login

import logging
import re
import requests
import os
logging.basicConfig(level=logging.INFO ,format="%(asctime)s %(filename)s %(funcName)s：line %(lineno)d %(levelname)s %(message)s")


class Post:
    def __init__(self, hostname, username, password, questionid='0', answer=None, cookies_flag=True,pub_url = ''):
        self.hostname = hostname 
        if pub_url !='':
            self.hostname = self.get_host(pub_url)

        self.discuz_login = login.Login(self.hostname, username, password, questionid, answer, cookies_flag)
    
    def login(self):
        self.discuz_login.main()
        self.session = self.discuz_login.session
        self.formhash = self.get_formhash()

    def get_formhash(self):
        rst = self.session.get(f'https://{self.hostname}/forum.php?mod=viewthread&tid=2995048&extra=page%3D1').text
        formhash = re.search(r'<input type="hidden" name="formhash" value="(.+?)" />', rst).group(1)
        return formhash
    
    def get_host(self,pub_url):  
        res = requests.get(pub_url)
        res.encoding = "utf-8"
        url = re.search(r'a href="https://(.+?)/".+?>.+?入口</a>', res.text)
        if url != None:
            url = url.group(1)
            logging.info(f'获取到最新的论坛地址:https://{url}')
            return url
        else:
            logging.error(f'获取失败，请检查发布页是否可用{pub_url}')
            return self.hostname

    def post(self):
        post_url = f'https://{self.hostname}/forum.php?mod=post&action=reply&fid=294&tid=2995048&extra=page%3D1&replysubmit=yes&infloat=yes&handlekey=fastpost&inajax=1'
        data = {
            'message': 'ddddddddddddddddddd',
            'formhash': self.formhash,
            'usesig': 1,
            'subject': ''
        }
        res = self.session.post(post_url, data=data).text
        # logging.info(res)
        if 'succeed' in res:
            logging.info('回复发送成功')
        else :
            logging.error('回复发送失败')

if __name__ == '__main__':
    hostname = 'jietiandi.net'
    username = os.getenv('USERNAME')
    password = os.getenv('PASSWORD')
    post = Post(hostname,username,password)
    post.login()
    post.post()
