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

from PyQt5.QtCore import QObject, QThread, pyqtSlot, pyqtSignal, pyqtProperty

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

    shareNeedAuthorization = pyqtSignal("QStringList", arguments=["urls"])
    readyToShare = pyqtSignal()
    noAccountsToShare = pyqtSignal()

    authorizeUrlGot = pyqtSignal(str, str,
        arguments=["accountType", "authorizeUrl"])
    accountAuthorized = pyqtSignal(str, str, str,
        arguments=["accountType", "uid", "username"])

    userRemoved = pyqtSignal(str, str, str,
        arguments=["accountType", "uid", "username"])

    def __init__(self):
        super(AccountsManager, self).__init__()
        self._sharing = False
        self._failed_accounts = []
        self._succeeded_accounts = []
        self._accounts_need_auth = []
        self._skipped_accounts = []
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

    @pyqtProperty(bool)
    def isSharing(self):
        return self._sharing

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
        accountInfo = db.fetchAccountByUID(accountType, userId)
        db.removeAccountByUID(accountType, userId)
        if str(self._accounts[accountType].uid) == str(userId):
            account = typeClassMap[accountType]()
            account.succeeded.connect(self._accountSucceeded)
            account.failed.connect(self._accountFailed)
            account.loginFailed.connect(self.loginFailed)
            account.authorizeUrlGot.connect(self.authorizeUrlGot)
            account.accountInfoGot.connect(self.handleAccountInfo)

            self._accounts[accountType] = account

        self.userRemoved.emit(accountType, userId, accountInfo[1])

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
        if self._sharing:
            if self._accounts_need_auth:
                accountType = self._accounts_need_auth.pop()
                self.getAuthorizeUrl(accountType)
            else:
                self.share(self._text, self._pic)

    @pyqtSlot(str)
    def skipAccount(self, accountType):
        self._skipped_accounts.append(accountType)

    @pyqtSlot(str, str)
    def tryToShare(self, text, pic):
        self._sharing = True
        self._text = getattr(self, "_text", text)
        self._pic = getattr(self, "_pic", pic)

        for (accountType, account) in self._accounts.items():
            if account.enabled and not account.valid():
                self._accounts_need_auth.append(accountType)

        if self._accounts_need_auth:
            self.shareNeedAuthorization.emit(self._accounts_need_auth)
        else:
            self.share(self._text, self._pic)

    @pyqtSlot()
    def share(self, text, pic):
        self.readyToShare.emit()
        self._sharing = False

        self._succeeded_accounts = []
        self._failed_accounts = []
        accounts = [y for (x, y) in self._accounts.items()
                    if x not in self._skipped_accounts]
        self._skipped_accounts = []

        if accounts:
            self._share_thread.text = text
            self._share_thread.pic = pic
            self._share_thread.accounts = accounts
            self._share_thread.start()
        else:
            self.noAccountsToShare.emit()

    def reshare(self):
        accounts = [self._accounts[x] for x in self._failed_accounts]
        self._share_thread.accounts = accounts
        self._share_thread.start()
