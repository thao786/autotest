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
//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require bootstrap.js
//= require chosen.jquery.js
//= require_tree .


$(document).on('turbolinks:load', function() {
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
                        location.reload();
                    else
                        location.reload('/tests');
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

function onSignIn(googleUser) {
    var profile = googleUser.getBasicProfile();
    var id_token = googleUser.getAuthResponse().id_token;
    console.log('ID: ' + profile.getId()); // Do not send to your backend! Use an ID token instead.
    console.log('Name: ' + profile.getName());
    console.log('Image URL: ' + profile.getImageUrl());
    console.log('Email: ' + profile.getEmail()); // This is null if the 'email' scope is not present.
    console.log('id_token: ' + id_token);
}


