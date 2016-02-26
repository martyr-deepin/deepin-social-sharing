#! /usr/bin/env python
# -*- coding: utf-8 -*-
#
# Copyright (C) 2015 Deepin Technology Co., Ltd.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.

import os
from PyQt5.QtCore import QSettings, QVariant

from constants import SINAWEIBO, TWITTER

_SECTION_ACCOUNTS = "accounts"
class SocialSharingSettings(QSettings):
    def __init__(self):
        super(SocialSharingSettings, self).__init__()
        self._init_settings()

    def _init_settings(self):
        if os.path.exists(self.fileName()): return

        self.beginGroup(_SECTION_ACCOUNTS)
        self.setValue(SINAWEIBO, "")
        self.setValue(TWITTER, "")
        self.endGroup()

    def getOption(self, group, option):
        self.beginGroup(group)
        value = self.value(option)
        self.endGroup()

        return value

    def setOption(self, group, option, value):
        self.beginGroup(group)
        self.setValue(option, QVariant(value))
        self.endGroup()

    def getCurrentUser(self, accountType):
        return self.getOption(_SECTION_ACCOUNTS, accountType)

    def setCurrentUser(self, accountType, user):
        self.setOption(_SECTION_ACCOUNTS, accountType, user)
