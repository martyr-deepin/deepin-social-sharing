import QtQuick 2.1
import QtQuick.Window 2.1
import Deepin.Widgets 1.0

DDialog {
    id: dialog
    x: (Screen.desktopAvailableWidth - width) / 2
    y: (Screen.desktopAvailableHeight - height) / 2
    width: 480 + 20
    height: 314

    Component.onCompleted: show()

    function setText(text) {
        share_content.setText(text)
    }

    function setScreenshot(path) {
        share_content.setScreenshot(path)
    }

    function authorizeAccount(accountType) {
        mainItem.showBrowser()
        _accounts_manager.getAuthorizeUrl(accountType)
    }

    Item {
        id: mainItem
        width: parent.width
        clip: true

        property var browser

        anchors.top: parent.top
        anchors.bottom: bottom_bar.top

        function getCurrentPage() {
            var pages = [share_content, accounts_list, accounts_pick_view]
            for (var i = 0; i < pages.length; i++) {
                if (pages[i].visible) return pages[i]
            }
            return null
        }

        function showBrowser() {
            var currentPage = getCurrentPage()
            if (currentPage) {
                currentPage.leftOut()
            }

            createBrowser()
        }

        function createBrowser() {
            if (browser) {
                browser.destroy()
                browser = null
            }
            browser = Qt.createQmlObject("import QtQuick 2.2; AuthBrowser {width: %1; height: %2}".arg(mainItem.width).arg(mainItem.height), mainItem, "browser")
            browser.visible = false
            browser.rightIn()
        }

        Connections {
            target: _accounts_manager

            onReadyToShare: dialog.hide()

            onNeedAuthorization: {
                mainItem.showBrowser()
                _accounts_manager.authorizeNextAccount()
            }

            onAuthorizeUrlGot: {
                var _accountType = accountType

                mainItem.browser.urlChanged.connect(function (url) {
                    var verifier = _accounts_manager.getVerifierFromUrl(_accountType, url)
                    if (verifier) {
                        mainItem.browser.leftOut()
                        _accounts_manager.handleVerifier(_accountType, verifier)
                    }
                })
                mainItem.browser.outAnimationDone.connect(function() {
                    _accounts_manager.tryToShare("", "")
                })
                mainItem.browser.setUrl(authorizeUrl)
            }

            onAccountAuthorized: {
                if (accounts_list.visible) {
                    accounts_list.selectItem(accountType)
                }
                if (accounts_pick_view.visible) {
                    accounts_pick_view.addUser(accountType, uid, username)
                    accounts_pick_view.selectUser(accountType, uid)
                }
            }

            onLoginFailed: _utils.notify(accountType + " login failed!!!")
        }

        ShareContent {
            id: share_content
            width: parent.width
            height: parent.height
        }

        AccountsList {
            id: accounts_list
            visible: false
            width: parent.width
            height: parent.height

            onAccountSelected: _accounts_manager.enableAccount(accountType)
            onAccountDeselected: _accounts_manager.disableAccount(accountType)
        }

        AccountsManagement {
            id: accounts_pick_view
            visible: false
            parentWindow: dialog
            width: parent.width
            height: parent.height

            onLogin: authorizeAccount(type)

            onSwitchUser: _accounts_manager.switchUser(type, uid)

            function updateView() {
                var accounts = _accounts_manager.getAllAccounts()
                for (var i = 0; i < accounts.length; i++) {
                    var uid = accounts[i][1]
                    var username = accounts[i][2]
                    accounts_pick_view.addUser(accounts[i][0], uid, username)
                }
                var currentAccounts = _accounts_manager.getCurrentAccounts()
                for (var i = 0; i < currentAccounts.length; i++) {
                    var uid = currentAccounts[i][1]
                    accounts_pick_view.selectUser(currentAccounts[i][0], uid)
                }
            }

            Component.onCompleted: updateView()
        }
    }

    ShareBottomBar {
        id: bottom_bar
        width: parent.width
        wordsLeft: 140 - share_content.wordCount

        anchors.bottom: parent.bottom
        anchors.bottomMargin: -5

        onAccountSelected: _accounts_manager.enableAccount(accountType)
        onAccountDeselected: _accounts_manager.disableAccount(accountType)

        onNextButtonClicked: {
            bottom_bar.state = "accounts_list"
            share_content.leftOut()
            accounts_list.rightIn()
        }

        onShareButtonClicked: {
            _accounts_manager.tryToShare(share_content.text, share_content.screenshot)
        }

        onOkButtonClicked: {
            bottom_bar.state = "share"
            accounts_pick_view.rightOut()
            share_content.leftIn()
        }

        Component.onCompleted: {
            var accounts = _accounts_manager.getCurrentAccounts()
            var filterMap = []
            for (var i = 0; i < accounts.length; i++) {
                if (accounts[i][1] && accounts[i][2]) {
                    filterMap.push(accounts[i][0])
                    _accounts_manager.enableAccount(accounts[i][0])
                    state = "share"
                }
            }
            lightUpIcons(filterMap)
        }
    }

    DImageButton {
        x: 10
        y: -17
        z: dialog.z + 1
        normal_image: "../images/users_manage_normal.png"
        hover_image: "../images/users_manage_hover.png"
        press_image: "../images/users_manage_press.png"
        visible: bottom_bar.state == "first_time" || bottom_bar.state == "share"

        onClicked: {
            bottom_bar.state = "accounts_manage"
            share_content.leftOut()
            accounts_pick_view.rightIn()
        }
    }
}
