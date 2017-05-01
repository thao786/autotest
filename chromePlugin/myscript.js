var acceptedOrigin = "http://localhost:3000";
var sessionId = '';
var tabId = 0;
var windowId = 0;

chrome.storage.local.get(function(data) {
    if (data.session_id.trim().length > 0) {
        sessionId = data.session_id;

        // check if session ID exists, to make sure the info is not from other sites
        $.ajax({
            dataType: "json",
            type: "post",
            data: {'session_id': sessionId},
            url: acceptedOrigin + '/api/check',
            success: function (result, status, xhr) {
                console.log(data);

                chrome.runtime.sendMessage({type: "tabId"}, function(response) {
                    tabId = response.tabId;
                    windowId = response.windowId;

                    // report opening this page
                    reportEvent({action_type: 'pageload',
                        scrollTop: $(window).scrollTop(),
                        scrollLeft: $(window).scrollLeft()});

                    bindEvents();
                });
            }
        });
    }
});


// listen for signal from test.com to:
// start/stop recording sessions
window.addEventListener("message", function(event) {
    // We only accept messages from test.com
    if (acceptedOrigin.indexOf(event.origin) < 0 ||
            event.data.type != 'FROM_PAGE')
    {
        return;
    }

    if (event.data.session_id) {
        sessionId = event.data.session_id;

        // check if session ID exists, to make sure the info is not from other sites
        $.ajax({
            dataType: "json",
            type: "post",
            data: {'session_id': sessionId},
            url: acceptedOrigin + '/api/check',
            success: function(result, status, xhr) {
                // set local storage
                chrome.storage.local.set({ session_id: sessionId }, function () {
                    // activate plugin's icon
                    chrome.runtime.sendMessage({type: "showPopup"});
                });
                bindEvents();
            }
        });
    }

    if (event.data.stop_recording) {
        chrome.storage.local.set({ session_id: '' }, function () {
            // de-activate plugin's icon
            chrome.runtime.sendMessage({type: "hidePopup"});
            location.reload();
        });
    }

    return true;

}, false);

function reportEvent(data) {
    if (window.location.origin.indexOf('://localhost') > 0 ||
        (data.action_type == 'click' && !data.valid))
        return;

    data.session_id = sessionId;
    data.stamp = Date.now();
    data.webpage = window.location.href;
    data.chrome_tab = tabId + '-' + windowId;
    data.screenwidth = screen.width;
    data.screenheight = screen.height;

    console.log(data);

    // can ONLY post to test.com
    $.ajax({
        dataType: "json",
        type: "post",
        data: data,
        url: acceptedOrigin + '/api/saveEvent',
        success: function(result, status, xhr) {
            if (result == 'false') {
                location.reload();
                $("*").off("click");
                $(window).unbind('scroll');
            }
        }
    });
}

function analyzeClick(obj) {
    var data = {action_type: 'click', valid: true,
        tag_name: obj.prop("tagName").toLowerCase()};
    var objId = obj.prop("id");
    var classes = obj.prop('class');
    var text = obj.text().trim();
    var href = obj.attr('href');
    var eq;

    // if <a>, report href
    if (data.tag_name == 'a' && href.length > 0) {
        var linkArray = $("a[href='" + href + "']").toArray();
        eq = linkArray.indexOf(obj[0]);
        data.selector = href;
        data.eq = eq;
        data.selectorType = 'href';
    }
    // if <button>, report text
    else if (data.tag_name == 'button' && text.length > 0) {
        var buttonArray = $("button:contains('"+text+"')").toArray();
        eq = buttonArray.indexOf(obj[0]);
        data.selector = text;
        data.eq = eq;
        data.selectorType = 'button';
    }
    else if (objId && objId.trim().length > 0) {
        data.selector = obj.prop("id");
        data.selectorType = 'id';
    }
    else if (classes.trim().length > 0) {
        var classArray = classes.split(/\s+/g);
        var selectorClass = '';
        var i;
        for (i = 0; i < classArray.length; i++) {
            selectorClass = selectorClass + '.' + classArray[i];
        }

        var objArray = $(selectorClass).toArray();
        eq = objArray.indexOf(obj[0]);
        data.selector = selectorClass;
        data.eq = eq;
        data.selectorType = 'css';
    }
    else { // report tag, search by text
        if (data.tag_name == 'html' || data.tag_name == 'body')
            data.valid = false;
        else {
            var tagArray = $(data.tag_name).toArray();
            eq = tagArray.indexOf(obj[0]);
            data.selector = data.tag_name;
            data.eq = eq;
            data.selectorType = 'tag';
        }
    }

    return data;
}

function bindEvents() {
	// never miss any action, give many results
	// but not the correct one
	$('*').click(function(e) {
        var data = analyzeClick($(this));
        data.x = e.pageX;
        data.y = e.pageY;

        reportEvent(data);
	});


	// detect accurately which element is being clicked,
	// but could miss important ones
	$(document).on("click", "*", function(e) {
        var data = analyzeClick($(e.target));
        data.x = e.pageX;
        data.y = e.pageY;

        reportEvent(data);
	});


	// listen to typing actions
	$(document).keypress(function(e) {
        var data = {action_type: 'keypress'};
        data.typed = String.fromCharCode(e.which);
        reportEvent(data);
	});


	$(document).on("scroll", function(e) {
        var data = {action_type: 'scroll'};
        data.scrollTop = $(window).scrollTop();
        data.scrollLeft = $(window).scrollLeft();
        reportEvent(data);
	});


    $(window).resize(function() {
        var data = {action_type: 'resize'};
        reportEvent(data);
    });
}