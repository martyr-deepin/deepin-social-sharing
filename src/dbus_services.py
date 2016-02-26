#! /usr/bin/env python
# -*- coding: utf-8 -*-
#
# Copyright (C) 2015 Deepin Technology Co., Ltd.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.

from PyQt5.QtCore import Q_CLASSINFO, pyqtSlot
from PyQt5.QtDBus import QDBusConnection, QDBusAbstractAdaptor

DBUS_NAME = "com.deepin.SocialSharing"
DBUS_PATH = "/com/deepin/SocialSharing"
session_bus = QDBusConnection.sessionBus()

class DeepinSocialSharingAdaptor(QDBusAbstractAdaptor):

    Q_CLASSINFO("D-Bus Interface", DBUS_NAME)
    Q_CLASSINFO("D-Bus Introspection",
                '  <interface name="com.deepin.SocialSharing">\n'
                '    <method name="Share">\n'
                '      <arg direction="in" type="s" name="appName"/>\n'
                '      <arg direction="in" type="s" name="appIcon"/>\n'
                '      <arg direction="in" type="s" name="text"/>\n'
                '      <arg direction="in" type="s" name="picture"/>\n'
                '    </method>\n'
                '  </interface>\n')

    def __init__(self, parent):
        super(DeepinSocialSharingAdaptor, self).__init__(parent)
        self.parent = parent

    @pyqtSlot(str, str, str, str)
    def Share(self, appName, appIcon, text, picture):
        return self.parent.share(appName, appIcon, text, picture)