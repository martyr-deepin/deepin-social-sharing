#! /usr/bin/env python
# -*- coding: utf-8 -*-

# Copyright (C) 2014~2016 Deepin, Inc.
#               2014~2016 PengHui
#
# Author:     PengHui <penghuilater@gmail.com>
# Maintainer: PengHui <penghuilater@gmail.com>
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

from PyQt5.QtGui import QCursor
from PyQt5.QtCore import QObject, pyqtSignal, pyqtSlot

from deepin_menu.menu import Menu

from i18n import _

right_click_menu = [
    ("_Copy", _("Copy")),
    ("_Paste", _("Paste")),
    ("_Cut", _("Cut")),
    None,
    ("_Exit", _("Exit")),
]

class MenuController(QObject):
    toolSelected = pyqtSignal(str, arguments=["selectedAction"])
    exitedSelected = pyqtSignal()

    def __init__(self):
        super(MenuController, self).__init__()


    def _menu_item_invoked(self, _id):

        if _id == "_Copy":
            self.toolSelected.emit("_Copy")
        if _id == "_Paste":
            self.toolSelected.emit("_Paste")
        if _id == "_Cut":
            self.toolSelected.emit("_Cut")

        if _id == "_Exit":
            self.exitedSelected.emit()

    @pyqtSlot()
    def show_menu(self):

        self.menu = Menu(right_click_menu)
        self.menu.itemClicked.connect(self._menu_item_invoked)
        self.menu.showRectMenu(QCursor.pos().x(), QCursor.pos().y())
