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

from account_base import AccountBase
from utils import getUrlQuery

APP_KEY = 'r2HHabDu8LDQCELxk2cA'
APP_SECRET = '9e4LsNOvxWVWeEgC5gthL9Q78F7FDsnT7lUIBruyQmI'
CALLBACK_URL = 'http://www.linuxdeepin.com'

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

    def valid(self):
        return self._access_token and self._access_token_secret

    def share(self, text, pic=None):
        if not self.enabled: return

        if pic:
            with open(pic, "rb") as _pic:
                self._client.api.statuses.update_with_media.post(status=text,
                                                                 media=_pic)
        else:
            self._client.api.statuses.update.post(status=text)

    def getAuthorizeUrl(self):
        self._client = UserClient(APP_KEY, APP_SECRET)
        token = self._client.get_authorize_token()
        self._access_token = token['oauth_token']
        self._access_token_secret = token['oauth_token_secret']

        return token['auth_url']

    def getVerifierFromUrl(self, url):
        query = getUrlQuery(url)
        return query.get("oauth_verifier")

    def getAccountInfoWithVerifier(self, verifier):
        token_info = self._client.get_access_token(verifier)
        info = (token_info["user_id"], token_info["screen_name"],
                token_info["oauth_token"], token_info["oauth_token_secret"])
        return info