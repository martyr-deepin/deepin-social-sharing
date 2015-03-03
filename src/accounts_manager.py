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

from PyQt5.QtCore import QObject, QThread, pyqtSlot, pyqtSignal

from settings import SocialSharingSettings

typeClassMap = {
    SINAWEIBO: SinaWeibo,
    TWITTER: Twitter,
}

class _ShareThread(QThread):
    def __init__(self, accounts=None, text=None, pic=None):
        super(_ShareThread, self).__init__()
        self.accounts = accounts
        self.text = text
        self.pic = pic

    def run(self):
        for account in self.accounts:
            account.share(self.text, self.pic)

class AccountsManager(QObject):
    """Manager of all the SNS accounts"""
    succeeded = pyqtSignal("QVariant")
    failed = pyqtSignal("QVariant")

    loginFailed = pyqtSignal(str, arguments=["accountType"])

    needAuthorization = pyqtSignal()

    authorizeUrlGot = pyqtSignal(str, str,
        arguments=["accountType", "authorizeUrl"])
    accountAuthorized = pyqtSignal(str, str, str,
        arguments=["accountType", "uid", "username"])

    def __init__(self):
        super(AccountsManager, self).__init__()
        self._failed_accounts = []
        self._succeeded_accounts = []
        self._share_thread = _ShareThread()
        self._settings = SocialSharingSettings()

        self._accounts = {}
        for _type in typeClassMap:
            self._accounts[_type] = self.getInitializedAccount(_type)
            account = self._accounts[_type]
            account.succeeded.connect(self._accountSucceeded)
            account.failed.connect(self._accountFailed)
            account.loginFailed.connect(self.loginFailed)
            account.authorizeUrlGot.connect(self.authorizeUrlGot)
            account.accountInfoGot.connect(self.handleAccountInfo)

    def _checkProgress(self):
        finished_accounts = self._failed_accounts + self._succeeded_accounts
        enabled_accounts = filter(lambda x: x.enabled, self._accounts.values())
        if len(finished_accounts) == len(enabled_accounts):
            if len(self._succeeded_accounts) > 0:
                self.succeeded.emit(self._succeeded_accounts)
            if len(self._failed_accounts) > 0:
                self.failed.emit(self._failed_accounts)

    def _accountFailed(self, account):
        self._failed_accounts.append(account)
        self._checkProgress()

    def _accountSucceeded(self, account):
        self._succeeded_accounts.append(account)
        self._checkProgress()

    def getInitializedAccount(self, accountType):
        account = typeClassMap[accountType]()
        records = db.fetchAccessableAccounts(accountType)
        if records:
            targetUID = self._settings.getCurrentUser(accountType)
            _records = filter(lambda x: x[0] == targetUID, records)
            if _records:
                account = typeClassMap[accountType](*_records[0])
            else:
                account = typeClassMap[accountType](*records[0])

        return account

    @pyqtSlot(result="QVariant")
    def getAllAccounts(self):
        result = []

        for _type in [SINAWEIBO, TWITTER]:
            for account in db.fetchAccounts(_type):
                result.append([_type, account[0], account[1]])

        return result

    @pyqtSlot(str)
    def enableAccount(self, accountType):
        self._accounts[accountType].enabled = True

    @pyqtSlot(str)
    def disableAccount(self, accountType):
        self._accounts[accountType].enabled = False

    @pyqtSlot(str, str)
    def switchUser(self, accountType, userId):
        accountInfo = db.fetchAccountByUID(accountType, userId)
        if accountInfo:
            account = typeClassMap[accountType](*accountInfo)
            account.succeeded.connect(self._accountSucceeded)
            account.failed.connect(self._accountFailed)
            account.loginFailed.connect(self.loginFailed)
            account.authorizeUrlGot.connect(self.authorizeUrlGot)
            account.accountInfoGot.connect(self.handleAccountInfo)

            self._accounts[accountType] = account
            self._settings.setCurrentUser(accountType, userId)

    @pyqtSlot(str, str)
    def removeUser(self, accountType, userId):
        db.removeAccountByUID(accountType, userId)

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
        return self._accounts[accountType].getVerifierFromUrl(url)

    @pyqtSlot(str, str)
    def handleVerifier(self, accountType, verifier):
        self._accounts[accountType].getAccountInfoWithVerifier(verifier)

    def handleAccountInfo(self, accountType, accountInfo):
        db.saveAccountInfo(accountType, accountInfo)
        uid = accountInfo[0]
        username = accountInfo[1]
        self.accountAuthorized.emit(accountType, uid, username)

    @pyqtSlot()
    def authorizeNextAccount(self):
        for (accountType, account) in self._accounts.items():
            if account.enabled and not account.valid():
                self.getAuthorizeUrl(accountType)
                return
        self.share(self._text, self._pic)

    @pyqtSlot(str, str)
    def tryToShare(self, text, pic):
        self._text = self._text if text == "" else text
        self._pic = self._pic if pic == "" else pic

        if not all(map(lambda x:x.enabled and x.valid(),
                       self._accounts.values())):
            self.needAuthorization.emit()
        else:
            self.share(self._text, self._pic)

    @pyqtSlot()
    def share(self, text, pic):
        self._succeeded_accounts = []
        self._failed_accounts = []

        self._share_thread.text = text
        self._share_thread.pic = pic
        self._share_thread.accounts = self._accounts.values()
        self._share_thread.start()

    def reshare(self):
        self._share_thread.accounts = self._failed_accounts
        self._share_thread.start()
