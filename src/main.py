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

# set the environment variable 'bo_reuse'(used by mesa) to 0, thus
# preventing the damage to our window blur effects.
import os
import re
os.environ['bo_reuse'] = '0'

import sys
import signal
import shutil
import tempfile
from glob import glob

from PyQt5.QtCore import QUrl, QObject, pyqtSlot
from PyQt5.QtQml import QQmlApplicationEngine
from PyQt5.QtWidgets import QApplication
app = QApplication(sys.argv)
app.setOrganizationName("Deepin")
app.setApplicationName("Deepin Social Sharing")
app.setApplicationVersion("1.0")
app.setQuitOnLastWindowClosed(True)

from i18n import _
from constants import MAIN_QML, IMAGE_EM, SINAWEIBO, TWITTER
from accounts_manager import AccountsManager
from dbus_services import DBUS_NAME, DBUS_PATH
from dbus_services import DeepinSocialSharingAdaptor, session_bus
from dbus_interfaces import NotificationsInterface

import face_data

ACTION_ID_RESHARE = "action_id_reshare"


class UIUtils(QObject):
    """Qt/UI related utils"""
    def __init__(self, notificationsInterface = None):
        super(UIUtils, self).__init__()
        self.notificationsInterface = notificationsInterface

    @pyqtSlot(str, str)
    def notify(self, summary, body):
        self.notificationsInterface.notify(summary, body)

    @pyqtSlot(str)
    def notifyContent(self, content):
        self.notificationsInterface.notifyBody(content)

    @pyqtSlot(str, result='QVariant')
    def facegetValue(self, str):
        value = face_data.getValue(str)
        return value



    @pyqtSlot(str, result='QVariant')
    def emojiFaceInfoList(self, emojiFaceDir):
        em_total_dir = IMAGE_EM
        emoji_face_list = sorted(glob(em_total_dir))
        sort_face_list = []
        for image_file in emoji_face_list:
            image_file = image_file.split("/")[-1]
            sort_face_list.append(image_file)
        emoji_image_list = []
        emoji_image_rest = []
        for image_file in sort_face_list:
            emoji_image_selected_first = re.compile(r"(1f6\w+).png")
            emoji_image_selected = emoji_image_selected_first.search(image_file)
            if emoji_image_selected == None:
                emoji_image_rest.append(image_file)
            else:
                emoji_image_list.append(emoji_image_selected.group(0))
        for image_file in emoji_image_rest:
            emoji_image_list.append(image_file)
        return emoji_image_list


    @pyqtSlot(str, result=str)
    def shareTextConvert(self, shareText):
        def faceGetKey(matchobj):
            codeString = matchobj.group(1)
            keyString = face_data.getKey(codeString)
            if keyString == 'default-value':
                return '['+codeString+']'
            else:
                keyString = int(keyString, 16)
                return unichr(keyString)

        contentPattern = re.compile(r"\[([0-9a-zA-Z\s]+)\]")
        share_text =contentPattern.sub(faceGetKey, shareText)
        return share_text

class QmlEngine(QQmlApplicationEngine):
    def __init__(self):
        super(QmlEngine, self).__init__()
        self._accounts_manager = AccountsManager()
        self._notificationId = None
        self._utils = UIUtils()

        self.rootContext().setContextProperty("_utils", self._utils)
        self.rootContext().setContextProperty("_accounts_manager",
                                              self._accounts_manager)

        self.load(QUrl.fromLocalFile(MAIN_QML))
        self.rootObject = self.rootObjects()[0]

        self._accounts_manager.succeeded.connect(self._shareSucceededCB)
        self._accounts_manager.failed.connect(self._shareFailedCB)

    def share(self, appName, appIcon, text, picture):
        self._notificationsInterface = NotificationsInterface(
            appName, appIcon)
        self._notificationsInterface.NotificationClosed.connect(
            self._notificationClosedCB)
        self._notificationsInterface.ActionInvoked.connect(
            self._actionInvokedCB)
        self._utils.notificationsInterface = self._notificationsInterface

        self._accounts_manager.appName = appName

        self.rootObject.setText(text)
        self.rootObject.setScreenshot(picture)
        self.rootObject.show()

    def _accountTypeName(self, accountType):
        nameDict = {
            SINAWEIBO: _("Weibo"),
            TWITTER: _("Twitter")
        }
        return nameDict.get(accountType, accountType)

    def _shareSucceededCB(self, accounts):
        accounts = map(lambda x: self._accountTypeName(x), accounts)
        accountsStr = _(",").join(accounts) if len(accounts) > 1 else accounts[0]
        self._notificationId = self._notificationsInterface.notify(
            _("Succeeded"),
            _("You have successfully shared the picture to %s") % accountsStr)

    def _shareFailedCB(self, accounts):
        accounts = map(lambda x: self._accountTypeName(x), accounts)
        accountsStr = _(",").join(accounts) if len(accounts) > 1 else accounts[0]
        self._notificationId = self._notificationsInterface.notify(
            _("Failed"),
            _("Sorry, failed to share the picture to %s") % accountsStr,
            [ACTION_ID_RESHARE, "Resend"])

    def _notificationClosedCB(self, notificationId, reason):
        if notificationId == self._notificationId:
            self.rootObject.close()

    def _actionInvokedCB(self, notificationId, actionId):
        if notificationId == self._notificationId:
            if actionId == ACTION_ID_RESHARE:
                self._accounts_manager.reshare()

class AppDelegate(QObject):
    def __init__(self):
        super(AppDelegate, self).__init__()
        self._engines = []
        self._adapter = DeepinSocialSharingAdaptor(self)

    def share(self, appName, appIcon, text, picture):
        temp = tempfile.mktemp()
        shutil.copyfile(picture, temp)

        engine = QmlEngine()
        engine.share(appName, appIcon, text, temp)
        self._engines.append(engine)

if __name__ == "__main__":
    delegate = AppDelegate()

    session_bus.registerService(DBUS_NAME)
    session_bus.registerObject(DBUS_PATH, delegate)

    signal.signal(signal.SIGINT, signal.SIG_DFL)
    sys.exit(app.exec_())
