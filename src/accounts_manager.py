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

from accounts import SinaWeibo, Twitter
from database import db, SINAWEIBO, TWITTER

from PyQt5.QtCore import QObject, pyqtSlot

typeClassMap = {
    SINAWEIBO: SinaWeibo,
    TWITTER: Twitter,
}

class AccountsManager(QObject):
    """Manager of all the SNS accounts"""
    def __init__(self):
        super(AccountsManager, self).__init__()
        self._accounts = {}
        for _type in typeClassMap:
            self._accounts[_type] = self.getInitializedAccount(_type)

    def getInitializedAccount(self, accountType):
        account = typeClassMap[accountType]()
        records = db.fetchAccessableAccounts(accountType)
        if records: account = typeClassMap[accountType](*records[0])

        return account

    @pyqtSlot(str)
    def enableAccount(self, accountType):
        self._accounts[accountType].enabled = True

    @pyqtSlot(result="QVariant")
    def getCurrentAccounts(self):
        result = []
        for _account in self._accounts:
            account = self._accounts[_account]
            result.append([_account, account.uid, account.username])
        return result

    @pyqtSlot(str, result=str)
    def getAuthorizeUrl(self, accountType):
        return self._accounts[accountType].getAuthorizeUrl()

    @pyqtSlot(str, str, result=str)
    def getVerifierFromUrl(self, accountType, url):
        print accountType, url, self._accounts
        print self._accounts[accountType].getVerifierFromUrl(url)
        return self._accounts[accountType].getVerifierFromUrl(url)

    @pyqtSlot(str, str)
    def handleVerifier(self, accountType, verifier):
        info = self._accounts[accountType].getAccountInfoWithVerifier(verifier)
        db.saveAccountInfo(accountType, info)

    @pyqtSlot(str, str)
    def share(self, text, pic):
        for _account in self._accounts:
            self._accounts[_account].share(text, pic)
