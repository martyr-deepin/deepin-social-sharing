#! /usr/bin/env python
# -*- coding: utf-8 -*-

# Copyright (C) 2014 ~ 2015 Deepin, Inc.
#               2014 ~ 2015 Wang Yaohua
#
# Author:     Wang Yaohua <mr.asianwang@gmail.com>
# Maintainer: Wang Yaohua <mr.asianwang@gmail.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

from _sdks.facebook_sdk import GraphAPI, auth_url

from account_base import AccountBase, TimeoutThread
from utils import getUrlQuery
from constants import FACEBOOK, ShareFailedReason

import time
from PyQt5.QtCore import pyqtSignal

APP_KEY = '350697548453021'
APP_SECRET = 'ad29931179f111e2790be14023bac6a5'
CALLBACK_URL = 'http://www.linuxdeepin.com/'

class GetAccountInfoThread(TimeoutThread):
    getAccountInfoFailed = pyqtSignal()
    accountInfoGot = pyqtSignal("QVariant", arguments=["accountInfo"])

    def __init__(self, client=None, verifier=None):
        super(GetAccountInfoThread, self).__init__()
        self._client = client
        self._verifier = verifier
        self.timeout.connect(self.getAccountInfoFailed)

    def setClient(self, client):
        self._client = client

    def setVerifier(self, verifier):
        self._verifier = verifier

    def run(self):
        try:
            token_info = self._client.get_access_token_from_code(
                self._verifier,
                CALLBACK_URL,
                APP_KEY,
                APP_SECRET)
            self._client.access_token = token_info["access_token"]
            account_info = self._client.get_object(id="me")
            info = [account_info["id"], account_info["name"],
                    token_info["access_token"],
                    int(token_info["expires"]) + time.time()]
            self.accountInfoGot.emit(info)
        except Exception:
            self.getAccountInfoFailed.emit()

class Facebook(AccountBase):
    def __init__(self, uid='', username='', access_token='', expires=0):
        super(Facebook, self).__init__()
        self.uid = uid
        self.username = username
        self.expires = expires

        self._client = GraphAPI(access_token=access_token, version='2.3')

        self._getAccountInfoThread = GetAccountInfoThread(self._client)
        self._getAccountInfoThread.accountInfoGot.connect(
            self.handleAccountInfoGot)
        self._getAccountInfoThread.getAccountInfoFailed.connect(
            lambda: self.loginFailed.emit(FACEBOOK))

    def handleAccountInfoGot(self, info):
        self.accountInfoGot.emit(FACEBOOK, info)
        self.uid = info[0]
        self.username = info[1]
        self.expires = info[3]

    def valid(self):
        return self._client.access_token and self.expires > time.time()

    def share(self, text, pic=None):
        if not self.enabled: return

        try:
            if pic:
                with open(pic) as _pic:
                    self._client.put_photo(message=text, image=_pic)
            else:
                self._client.put_object("me", "feed", message=text)
            self.succeeded.emit(FACEBOOK)
        except Exception, e:
            if e.type == 1153:
                self.failed.emit(FACEBOOK, ShareFailedReason.Authorization)
            else:
                self.failed.emit(FACEBOOK, ShareFailedReason.Other)

    def getAuthorizeUrl(self):
        self.authorizeUrlGot.emit(FACEBOOK,
            auth_url(APP_KEY, CALLBACK_URL, scope=["publish_actions"]))

    def cancelGetAuthorizeUrl(self): pass

    def getVerifierFromUrl(self, url):
        query = getUrlQuery(url)
        return query.get("code")

    def getAccountInfoWithVerifier(self, verifier):
        self._getAccountInfoThread.setClient(self._client)
        self._getAccountInfoThread.setVerifier(verifier)
        self._getAccountInfoThread.start()

    def generateTag(self, text):
        return "#%s " % text