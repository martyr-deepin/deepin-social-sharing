import QtQuick 2.1
import QtQuick.Window 2.1
import Deepin.Widgets 1.0
import Deepin.Locale 1.0

DDialog {
    id: dialog
    x: (Screen.desktopAvailableWidth - width) / 2
    y: (Screen.desktopAvailableHeight - height) / 2

    property int lastX: x
    property int lastY: y

    Component.onCompleted: { _show(); show() }

    function dsTr(src) { return locale.dsTr(src) }

    function setText(text) {
        share_content.setText(text)
    }

    function setScreenshot(path) {
        share_content.setScreenshot(path)
    }

    function authorizeAccount(accountType) {
        auth_browser.reset()
        auth_browser.rightIn()
        _accounts_manager.getAuthorizeUrl(accountType)
    }

    // below two functions are just workarounds to the issue that
    // WebView or something will crash if the top window they are in
    // shows again after hiding for a while.
    function _hide() {
        lastX = x
        lastY = y
        width = 1
        height = 1
    }

    function _show() {
        width = 480 + 20
        height = 314
        x = lastX
        y = lastY
    }

    Item {
        id: mainItem
        width: parent.width
        clip: true
        focus: true

        property var browser

        anchors.top: parent.top
        anchors.bottom: bottom_bar.top

        DLocale { id: locale; domain: "deepin-social-sharing" }

        function getCurrentPage() {
            var pages = [share_content, accounts_list, accounts_pick_view]
            for (var i = 0; i < pages.length; i++) {
                if (pages[i].visible) return pages[i]
            }
            return null
        }

        // steal focus from share_content, thus to make the TextEdit
        // response to a click event outside itself.
        MouseArea {
            anchors.fill: parent
            onClicked: mainItem.focus = true
        }

        Connections {
            target: _accounts_manager

            onReadyToShare: dialog._hide()

            onNoAccountsToShare: dialog.close()

            onShareNeedAuthorization: {
                dialog._show()

                auth_browser.reset()
                auth_browser.rightIn()
                _accounts_manager.authorizeNextAccount()
            }

            onAuthorizeUrlGot: {
                auth_browser.setAccountType(accountType)
                auth_browser.setUrl(authorizeUrl)
            }

            onAccountAuthorized: {
                accounts_pick_view.updateView()
                accounts_pick_view.selectUser(accountType, uid)
            }

            onUserRemoved: {
                accounts_pick_view.updateView()
            }

            // onLoginFailed: {
            //     _utils.notifyContent(accountType + " login failed!!!")
            //     if (_accounts_manager.isSharing) {
            //         auth_browser.next()
            //         _accounts_manager.authorizeNextAccount()
            //     } else {
            //         auth_browser.leftOut()
            //     }
            // }
        }

        ShareContent {
            id: share_content
            width: parent.width
            height: parent.height

            onTextOverflow: bottom_bar.warnWordsCount()
            onTextInBounds: bottom_bar.showWordsCount()
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
                accounts_pick_view.clearUsers()

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

        Keys.onReturnPressed: {
            if (event.modifiers & Qt.ControlModifier) {
                _accounts_manager.tryToShare(share_content.text, share_content.screenshot)
            }
        }
    }

    ShareBottomBar {
        id: bottom_bar
        width: parent.width
        wordsLeft: 140 - share_content.wordCount
        shareEnabled: anyPlatform() || accounts_list.anyPlatform()

        anchors.bottom: parent.bottom
        anchors.bottomMargin: -5

        function updateView() {
            var accounts = _accounts_manager.getCurrentAccounts()
            var filterMap = []
            var userExistsFlag = false
            for (var i = 0; i < accounts.length; i++) {
                if (accounts[i][1] && accounts[i][2]) {
                    filterMap.push(accounts[i][0])
                    _accounts_manager.enableAccount(accounts[i][0])
                    if (state == "first_time") state = "share"
                    userExistsFlag = true
                }
            }
            lightUpIcons(filterMap)

            if (!userExistsFlag && state == "share") {
                state = "first_time"
            }
        }

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
            updateView()
            accounts_pick_view.rightOut()
            share_content.leftIn()
        }

        onBackButtonClicked: {
            bottom_bar.state = "first_time"
            accounts_list.rightOut()
            share_content.leftIn()
        }

        Component.onCompleted: updateView()
    }

    DImageButton {
        x: 14
        y: 14
        parent: mainItem.parent.parent.parent
        normal_image: "../../images/users_manage_normal.png"
        hover_image: "../../images/users_manage_hover.png"
        press_image: "../../images/users_manage_press.png"
        visible: bottom_bar.state == "first_time" || bottom_bar.state == "share"

        onClicked: {
            bottom_bar.state = "accounts_manage"
            share_content.leftOut()
            accounts_pick_view.rightIn()
        }
    }

    // TODO: make all the positioning numbers meaningful
    Item {
        y: -24
        width: 484
        height: 298

        AuthBrowser {
            id: auth_browser
            width: parent.width
            height: parent.height
            visible: false
            radius: 3
            canSkip: _accounts_manager.hasNextToAuth

            onBack: auth_browser.rightOut()

            onSkipped: {
                _accounts_manager.skipAccount(accountType)

                if (_accounts_manager.isSharing) {
                    if (_accounts_manager.hasNextToAuth) {
                        auth_browser.next()
                        _accounts_manager.authorizeNextAccount()
                    }
                } else {
                    auth_browser.leftOut()
                }
            }

            onUrlChanged: {
                if (!accountType) return

                var verifier = _accounts_manager.getVerifierFromUrl(accountType, url)
                if (verifier) {
                    _accounts_manager.handleVerifier(accountType, verifier)
                    if (_accounts_manager.isSharing) {
                        if (_accounts_manager.hasNextToAuth) {
                            auth_browser.next()
                            _accounts_manager.authorizeNextAccount()
                        }
                    } else {
                        auth_browser.leftOut()
                    }
                }
            }
        }
    }
}
