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

import os

HOME = os.path.expanduser('~')
XDG_CONFIG_HOME = os.environ.get('XDG_CONFIG_HOME') or \
                  os.path.join(HOME, '.config')
PROJECT_NAME = "deepin-social-sharing"
CONFIG_DIR = os.path.join(XDG_CONFIG_HOME, PROJECT_NAME)
DATABASE_FILE = os.path.join(CONFIG_DIR, "accounts.db")

_parentDir = os.path.dirname(os.path.abspath(__file__))
_qmlDir = os.path.join(_parentDir, "qmls")
MAIN_QML = os.path.join(_qmlDir, "Share.qml")

if not os.path.exists(CONFIG_DIR): os.makedirs(CONFIG_DIR)

SINAWEIBO = "sinaweibo"
TWITTER = "twitter"