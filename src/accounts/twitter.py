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

from _sdks.twitter_sdk import UserClient

from account_base import AccountBase, TimeoutThread
from utils import getUrlQuery
from database import TWITTER

from PyQt5.QtCore import pyqtSignal

APP_KEY = 'r2HHabDu8LDQCELxk2cA'
APP_SECRET = '9e4LsNOvxWVWeEgC5gthL9Q78F7FDsnT7lUIBruyQmI'
CALLBACK_URL = 'http://www.linuxdeepin.com'

class GetAuthorizeUrlThread(TimeoutThread):
    getAuthorizeUrlFailed = pyqtSignal()
    authorizeUrlGot = pyqtSignal(str, arguments=["authorizeUrl"])

    def __init__(self, client=None):
        super(GetAuthorizeUrlThread, self).__init__()
        self._client = client
        self.timeout.connect(self.getAuthorizeUrlFailed)

    def setClient(self, client):
        self._client = client

    def run(self):
        try:
            token = self._client.get_authorize_token()
            self._access_token = token['oauth_token']
            self._access_token_secret = token['oauth_token_secret']
            self.authorizeUrlGot.emit(token["auth_url"])
        except Exception:
            self.getAuthorizeUrlFailed.emit()

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
            token_info = self._client.get_access_token(self._verifier)
            info = [token_info["user_id"], token_info["screen_name"],
                    token_info["oauth_token"], token_info["oauth_token_secret"]]
            self.accountInfoGot.emit(info)
        except Exception:
            self.getAccountInfoFailed.emit()

class Twitter(AccountBase):
    def __init__(self, uid='', username='',
                 access_token='', access_token_secret=''):
        super(Twitter, self).__init__()
        self.uid = uid
        self.username = username

        self._access_token = access_token
        self._access_token_secret = access_token_secret
        self._client = UserClient(APP_KEY,
                                  APP_SECRET,
                                  access_token,
                                  access_token_secret)

        self._getAuthorizeUrlThread = GetAuthorizeUrlThread(self._client)
        self._getAuthorizeUrlThread.authorizeUrlGot.connect(
            lambda x: self.authorizeUrlGot.emit(TWITTER, x))
        self._getAuthorizeUrlThread.getAuthorizeUrlFailed.connect(
            lambda: self.loginFailed.emit(TWITTER))

        self._getAccountInfoThread = GetAccountInfoThread(self._client)
        self._getAccountInfoThread.accountInfoGot.connect(
            lambda x: self.accountInfoGot.emit(TWITTER, x))
        self._getAccountInfoThread.getAccountInfoFailed.connect(
            lambda: self.loginFailed.emit(TWITTER))

    def valid(self):
        return bool(self._client.access_token and self._client.access_token_secret)

    def share(self, text, pic=None):
        if not self.enabled: return

        try:
            if pic:
                with open(pic, "rb") as _pic:
                    self._client.api.statuses.update_with_media.post(status=text,
                                                                     media=_pic)
            else:
                self._client.api.statuses.update.post(status=text)
            self.succeeded.emit(TWITTER)
        except Exception:
            self.failed.emit(TWITTER)

    def getAuthorizeUrl(self):
        self._client = UserClient(APP_KEY, APP_SECRET)
        self._getAuthorizeUrlThread.setClient(self._client)
        self._getAuthorizeUrlThread.start()

    def getVerifierFromUrl(self, url):
        query = getUrlQuery(url)
        return query.get("oauth_verifier")

    def getAccountInfoWithVerifier(self, verifier):
        self._getAccountInfoThread.setClient(self._client)
        self._getAccountInfoThread.setVerifier(verifier)
        self._getAccountInfoThread.start()