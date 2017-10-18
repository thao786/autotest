// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery_ujs
//= require chosen.jquery.js
//= require_tree .

var google_id = '548695467567-70v8t3gjff0itqom18mm2rdhtbqmlnnp.apps.googleusercontent.com';

$(document).ready(function() {
    $(document).on("click", ".add-test-modal", function(e) {
        var suite_id = $(this).data('suite');

        $.ajax({
            type: "GET",
            url: '/tests/new',
            data: {suite_id: suite_id},
            success: function(html, status, xhr) {
                $('body').append(html);
                $('#newTestModal').modal();
            }
        });
    });

    $(document).on("click", ".add-suite-modal", function(e) {
        $.ajax({
            type: "GET",
            url: '/suites/new',
            success: function(html, status, xhr) {
                $('body').append(html);
                $('#newSuiteModal').modal();
            }
        });
    });

    $(document).on("click", ".remove-test-tr", function(e) {
        if (confirm('Are you sure to delete this test?')) {
            var test_id = $(this).data('test');

            $.ajax({
                type: "DELETE",
                url: '/tests/' + test_id,
                data: {test_id: test_id},
                success: function(html, status, xhr) {
                    if (window.location.pathname.match(/test\/.+\/[0-9]+/g))
                        window.location.href = '/tests';
                    else
                        location.reload();
                }
            });
        }
    });

    $(document).on("click", ".remove-suite", function(e) {
        if (confirm('Are you sure to delete this suite and its tests?')) {
            var suite_id = $(this).data('test');
            var tr = $(this).closest('tr');

            $.ajax({
                type: "DELETE",
                url: '/tests/' + test_id,
                data: {test_id: test_id},
                success: function(html, status, xhr) {
                    tr.remove();
                }
            });
        }
    });

});

function showEditTestModal(test_id) {
    $.ajax({
        type: "GET",
        url: '/tests/' + test_id + '/edit', // /tests/1/edit
        data: {test_id: test_id},
        success: function(html, status, xhr) {
            $('body').append(html);
            $('#newTestModal').modal();
            modalFunction();
        }
    });
}

jQuery(function() {
    return $.ajax({
        url: 'https://apis.google.com/js/client:plus.js?onload=gpAsyncInit',
        dataType: 'script',
        cache: true
    });
});

window.gpAsyncInit = function() {
    gapi.auth.authorize({
        immediate: true,
        response_type: 'code',
        cookie_policy: 'single_host_origin',
        client_id: google_id,
        scope: 'email profile'
    }, function(response) {
        return;
    });
    $('.googleplus-login').click(function(e) {
        e.preventDefault();
        gapi.auth.authorize({
            immediate: false,
            response_type: 'code',
            cookie_policy: 'single_host_origin',
            client_id: google_id,
            scope: 'email profile'
        }, function(response) {
            if (response && !response.error) {
                // google authentication succeed, now post data to server.
                jQuery.ajax({type: 'POST', url: '/auth/google_oauth2/callback', data: response,
                    success: function(data) {
                        // response from server
                    }
                });
            } else {
                // google authentication failed
            }
        });
    });
};



function getBrowser() {
    if (typeof chrome !== "undefined") {
        if (typeof browser !== "undefined") {
            return "Firefox";
        } else {
            return "Chrome";
        }
    } else {
        return "Edge";
    }
}