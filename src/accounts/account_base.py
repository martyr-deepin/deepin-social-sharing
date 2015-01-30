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

from abc import abstractmethod

from PyQt5.QtCore import QObject, pyqtSignal

class AccountBase(QObject):
    """Base class all the SNS accounts should inherit"""
    succeeded = pyqtSignal(str)
    failed = pyqtSignal(str)

    def __init__(self):
        super(AccountBase, self).__init__()
        self.enabled = False

    @abstractmethod
    def valid(self): pass

    @abstractmethod
    def share(self, text, pic): pass

    @abstractmethod
    def getAuthorizeUrl(self): pass

    @abstractmethod
    def getVerifierFromUrl(self, url): pass

    @abstractmethod
    def getAccountInfoWithVerifier(self, verifier): pass