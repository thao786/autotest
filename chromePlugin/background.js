chrome.runtime.onMessage.addListener(
    function(request, sender, sendResponse) {
        if (request.type == 'showPopup') {
            chrome.browserAction.setIcon({path: 'activated.png'});
            chrome.browserAction.setPopup({popup: "activated.html"});
        }

        if (request.type == 'hidePopup') {
            chrome.browserAction.setIcon({path: 'inactive.png'});
            chrome.browserAction.setPopup({popup: "popup.html"});
        }

        if (request.type == 'tabId') {
            var tabId = '';
            chrome.tabs.query(
                { currentWindow: true, active: true },
                function (tabArray) {
                    sendResponse({tabId: tabArray[0].id, windowId: tabArray[0].windowId});
                }
            );
        }

        return true;
    }
);





