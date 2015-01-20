from PyQt5.QtCore import Q_CLASSINFO, pyqtSlot
from PyQt5.QtDBus import QDBusConnection, QDBusAbstractAdaptor

DBUS_NAME = "com.deepin.DeepinShare"
DBUS_PATH = "/com/deepin/DeepinShare"
session_bus = QDBusConnection.sessionBus()

class DeepinShareServiceAdaptor(QDBusAbstractAdaptor):

    Q_CLASSINFO("D-Bus Interface", DBUS_NAME)
    Q_CLASSINFO("D-Bus Introspection",
                '  <interface name="com.deepin.DeepinShare">\n'
                '    <method name="Share">\n'
                '      <arg direction="in" type="s" name="text"/>\n'
                '      <arg direction="in" type="s" name="picture"/>\n'
                '    </method>\n'
                '  </interface>\n')

    def __init__(self, parent):
        super(DeepinShareServiceAdaptor, self).__init__(parent)
        self.parent = parent

    @pyqtSlot(str, str)
    def Share(self, text, picture):
        return self.parent.share(text, picture)