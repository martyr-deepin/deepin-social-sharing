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

HOME = os.path.expanduser('~')
XDG_CONFIG_HOME = os.environ.get('XDG_CONFIG_HOME') or \
                  os.path.join(HOME, '.config')
PROJECT_NAME = "deepin-social-sharing"
CONFIG_DIR = os.path.join(XDG_CONFIG_HOME, PROJECT_NAME)
DATABASE_FILE = os.path.join(CONFIG_DIR, "accounts.db")

_parentDir = os.path.dirname(os.path.abspath(__file__))
IMAGE_EM = os.path.join(os.path.dirname(_parentDir), "images/selected_emoji/*.png")
_qmlDir = os.path.join(_parentDir, "qmls")
MAIN_QML = os.path.join(_qmlDir, "Share.qml")

if not os.path.exists(CONFIG_DIR): os.makedirs(CONFIG_DIR)

SINAWEIBO = "sinaweibo"
TWITTER = "twitter"
#FACEBOOK = "facebook"

class ShareFailedReason(object):
    Authorization = 0
    Other = 10
