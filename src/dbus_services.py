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