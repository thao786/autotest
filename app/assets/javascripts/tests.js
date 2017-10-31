var testUrl = window.location.pathname;
var sessionId = '';
var test_id;
var test_param_count = 0; //initlal text box count

$(document).ready(function() {
test_id = $("#page_info").data('test');

$('#startRecording').click(function() {
    if (isChrome()) {
        testUrl = window.location.pathname;
        sessionId = '';

        // get the session ID
        $.ajax({
            type: "GET",
            url: '/tests/generateSession',
            dataType: "text",
            data: {test_id: test_id},
            success: function (result, status, xhr) {
                sessionId = result;
                $('#notice').html('All your activities on Chrome will be recorded. Please make sure chrome extension is installed.');

                // activate the Chrome Plugin
                window.postMessage({
                    type: "FROM_PAGE",
                    session_id: sessionId,
                    host: window.origin
                }, "*");

                location.reload();
            }
        });
    } else {
        alert('Record Steps only work on Google Chrome. Please switch browser and install Chrome Extension');
    }
});

$('#stopRecording').click(function() {
    // set the session ID expired rate
    $.ajax({
        type: "GET",
        url: '/tests/stopSession',
        dataType: "text",
        data: {test_id: test_id},
        success: function(result, status, xhr) {
            sessionId = '';
            $('#notice').html('Your recording session has stop.');

            // de-activate the Chrome Plugin
            window.postMessage({ type: "FROM_PAGE", stop_recording: 1 }, "*");

            location.reload();
        }
    });
});


$("body").on('mouseenter', '.step-list-item', function() {
    $(this).find('.visible-hover').show();
}).on('mouseleave', '.step-list-item', function() {
    $('.visible-hover').hide();
});

$("#add-test-params").click(function(e){ //on add input button click
    $.ajax({
        type: "GET",
        url: '/tests/add_new_param',
        data: {test_id: test_id},
        success: function(html, status, xhr) {
            $('body').append(html);
            $('#addTestModal').modal();
            modalFunction();
            test_param_count++; //text box increment
            var html = $('#copyable .empty-test-params')[0].outerHTML;
            $('#test-params-input-list').append(html);
        },
        error: function(result, status, xhr) {
            alert('Sorry, we cannot add test parameter at this time.');
        }
    });
});

$(document).on("click", "#add-more-test", function(e) {  
    e.preventDefault();
    test_param_count++; //text box increment
    var html = $('#copyable .empty-test-params')[0].outerHTML;
    $('#test-params-input-list').append(html);
});

$(document).on("click", "#submit-test-params", function(e) {  
    var param_names = [];
    $("#test-params-input-list input[name*='param_names']").each(function(){
        param_names.push($(this).val());
    });
    var param_values = [];
    $("#test-params-input-list input[name*='param_values']").each(function(){
        param_values.push($(this).val());
    });

    $.ajax({
        type: "POST",
        url: '/tests/addTestParams',
        data: {test_id: test_id, param_names: param_names, param_values: param_values},
        success: function(result, status, xhr) {
            $("#test_params").html(result);
            $("#test-params-input-list").html('');
            $('#addTestModal').modal('toggle');
        },
        error: function(result, status, xhr) {
            $('.error-modal').html(result.responseText);
        }
    });
});

$(".step-list-item .hover-edit-btn").on("click", function(e) { // add more headers
    var step_id = $(this).closest('.step-list-item').data('step');

    $.ajax({
        type: "GET",
        url: '/step/edit_view',
        data: {step_id: step_id},
        success: function(html, status, xhr) {
            $('body').append(html);
            $('#stepModal').modal();
            modalFunction();
        },
        error: function(result, status, xhr) {
            alert('Sorry, we could not remove steps at this time.');
        }
    });
});

});

$(document).on("click", ".delete-step", function(e) {
    var step_id = $(this).closest('.step-list-item').data('step');
    var list_item = $(this).parent();

    if(confirm('Are you sure you would like to delete this step?')) {
        $.ajax({
            type: "GET",
            url: '/step/delete_step',
            dataType: "text",
            data: {step_id: step_id},
            success: function(result, status, xhr) {
                list_item.remove();           
                location.reload();

            }
        });
    }
});

$(document).on("click", ".remove-test-param", function(e) { //user click on remove text
    e.preventDefault();

    // check if this remove active parameters
    var key = $(this).data('key');
    var thisEl = $(this);

    if (key) {
        $.ajax({
            type: "POST",
            url: '/tests/removeTestParams',
            data: {test_id: test_id, key: key},
            success: function(result, status, xhr) {
                thisEl.parent('div').remove();
                test_param_count--;
            },
            error: function(result, status, xhr) {
                alert('Sorry, we could not remove a parameter at this time.');
            }
        });
    } else {
        thisEl.parent('div').remove();
        test_param_count--;
    }

    if (test_param_count == 0)
        $('#submit-test-params').hide();
});

$(document).on("click", ".remove-webpage-param", function(e) {
    e.preventDefault();
    $(this).parent().remove();
});

$(document).on("click", "#add-headers", function(e) {
    e.preventDefault();
    var inputCombo = $('#copyable .empty-header-params')[0].outerHTML;
    $("#header-list").append(inputCombo);
});

$(document).on("click", "#add-pageload-param", function(e) {
    e.preventDefault();
    var inputCombo = $('#copyable .empty-pageload-params')[0].outerHTML;
    $("#pageload-param-list").append(inputCombo);
});

$(document).on("click", "#add-empty-extract", function(e) {
    e.preventDefault();
    var inputCombo = $('#copyable .empty-extract-param')[0].outerHTML;
    $("#empty-extract-list").append(inputCombo);
});

$(document).on("click", ".hash-pair .remove-header-param", function(e) {
    var step_id = $(this).closest('.modal.fade').data('step');
    var glyp = $(this);

    $.ajax({
        type: "POST",
        url: '/step/remove_header_param',
        data: {step_id: step_id,
            key: $(this).data('key')
        },
        success: function(html, status, xhr) {
            glyp.parent().remove();
        },
        error: function(result, status, xhr) {
            alert('Sorry, we could not step data at this time.');
        }
    });
});

$(document).on("click", ".hash-pair .remove-pageload-param", function(e) {
    var step_id = $(this).closest('.modal.fade').data('step');
    var glyp = $(this);

    $.ajax({
        type: "POST",
        url: '/step/remove_pageload_param',
        data: {step_id: step_id,
            key: $(this).data('key')
        },
        success: function(html, status, xhr) {
            glyp.parent().remove();
        },
        error: function(result, status, xhr) {
            alert('Sorry, we could not save step data at this time.');
        }
    });
});

$(document).on("click", ".empty-header-params .remove-header-param," +
    ".empty-pageload-params .empty-pageload-params, .remove-pageload-param," +
    " .empty-extract-param .remove-extract-param", function(e) {
    $(this).parent().remove();
});

$(document).on("click", ".add-step-after, #addNewStep", function(e) {
    var step_id = $(this).closest('.step-list-item').data('step');

    $.ajax({
        type: "GET",
        url: '/step/add_step_view',
        data: {step_id: step_id, test_id: test_id},
        success: function(html, status, xhr) {
            $('body').append(html);
            $('#newStepModal').modal();
            modalFunction();
        },
        error: function(result, status, xhr) {
            alert('Sorry, we could not remove a parameter at this time.');
        }
    });
});

$(document).on("click", "#add-assertion", function(e) {
    $.ajax({
        type: "GET",
        url: '/assertions/newAssertionView',
        data: {test_id: test_id},
        success: function(html, status, xhr) {
            $('body').append(html);
            $('#addAssertionModal').modal();
            modalFunction();
        },
        error: function(result, status, xhr) {
            alert('Sorry, we could not remove a parameter at this time.');
        }
    });
});

$(document).on("click", ".remove-assertion", function(e) {
    if(confirm('Are you sure you would like to delete this assertion?')) {
        var assertionLabel = $(this).closest('.assertion');
        var assertion_id = assertionLabel.data('id');

        $.ajax({
            type: "POST",
            url: '/assertions/removeAssertion',
            data: {assertion_id: assertion_id},
            success: function(html, status, xhr) {
                assertionLabel.remove();
            },
            error: function(result, status, xhr) {
                alert('Sorry, we could not remove the assertion at this time.');
            }
        });
    }
});

$(document).on("click", ".disable-assertion", function(e) {
    var assertionLabel = $(this).closest('.assertion');
    var assertion_id = assertionLabel.data('id');

    $.ajax({
        type: "POST",
        url: '/assertions/disableAssertion',
        data: {assertion_id: assertion_id},
        success: function(html, status, xhr) {},
        error: function(result, status, xhr) {
            alert('Sorry, we could not remove a parameter at this time.');
        }
    });
});

$(document).on("click", ".remove-extract", function(e) {
    var extract_id = $(this).data('id');
    $(this).parent().remove();

    $.ajax({
        type: "POST",
        url: '/step/removeExtract',
        data: {extract_id: extract_id},
        success: function(html, status, xhr) {
        }
    });
});

$(document).on("click", ".show-config-modal", function(e) {
    var step_id = $(this).closest('.step-list-item').data('step');

    $.ajax({
        type: "GET",
        url: '/step/configModal',
        data: {step_id: step_id},
        success: function(html, status, xhr) {
            $('body').append(html);
            $('#stepConfigModal').modal();
            modalFunction();
        }
    });
});

/*
 STEP MODAL EDIT FORMS
 */

$(document).on("click", "#edit-pageload-form .submit", function(e) {
    var step_id = $(this).closest('.modal.fade').data('step');

    $.ajax({
        type: "POST",
        url: '/step/save_pageload',
        data: {step_id: step_id,
            form: $('#edit-pageload-form').serialize()
        },
        success: function(html, status, xhr) {
            $('.modal.fade').modal('hide');
            location.reload();
        },
        error: function(result, status, xhr) {
            $('.error-modal').html(result.responseText);
        }
    });
});

$(document).on("click", "#save-config .submit", function(e) {
    var step_id = $(this).closest('.modal.fade').data('step');

    $.ajax({
        type: "POST",
        url: '/step/saveConfig',
        data: {step_id: step_id,
            form: $('#save-config').serialize()
        },
        success: function(html, status, xhr) {
            $('.modal.fade').modal('hide');
            location.reload();
        },
        error: function(result, status, xhr) {
            $('.error-modal').html(result.responseText);
        }
    });
});

$(document).on("click", "#edit-keypress-form .submit", function(e) {
    var step_id = $(this).closest('.modal.fade').data('step');

    $.ajax({
        type: "POST",
        url: '/step/save_keypress',
        data: {step_id: step_id,
            form: $('#edit-keypress-form').serialize()
        },
        success: function(html, status, xhr) {
            $('.modal.fade').modal('hide');
            $("#step-list [data-step='" + step_id + "']").replaceWith(html);
            location.reload();
        },
        error: function(result, status, xhr) {
            alert('Sorry, we could not step data at this time.');
        }
    });
});

$(document).on("click", ".edit-click-form .submit", function(e) {
    var step_id = $(this).closest('.modal.fade').data('step');
    var form = $(this).closest('form');

    $.ajax({
        type: "POST",
        url: '/step/save_click',
        data: {step_id: step_id,
            form: form.serialize()
        },
        success: function(html, status, xhr) {
            $('.modal.fade').modal('hide');
            location.reload();
        },
        error: function(result, status, xhr) {
            $('.error-modal').html(result.responseText);
        }
    });
});

$(document).on("click", "#edit-scroll-form .submit", function(e) {
    var step_id = $(this).closest('.modal.fade').data('step');
    var form = $(this).closest('form');

    $.ajax({
        type: "POST",
        url: '/step/save_scroll',
        data: {step_id: step_id,
            form: $('#edit-scroll-form').serialize()
        },
        success: function(html, status, xhr) {
            $('.modal.fade').modal('hide');
            location.reload();
        },
        error: function(result, status, xhr) {
            $('.error-modal').html(result.responseText);
        }
    });
});

// to execute when test is done running
function restore_btn_menu() {
    $('#runTest').show(); // put back button menu
    $('#showRunningTest').hide();
}

function noti_timeout(msg, timeout) {
    $('#test_noti').show();
    $('#test_noti').html(msg);

    setTimeout(
        function () {
            $("#test_noti").fadeOut().empty();
        }
        , timeout);
}


$(document).on("click", "#runTest", function(e) {
    $('#runTest').hide(); // change to spinning icon
    $('#showRunningTest').show();
    var timeout = 10000; // 10 seconds

    $.ajax({
        type: "GET",
        url: '/tests/runTest',
        data: {test_id: test_id}
    });

    noti_timeout('Request to run test submitted. Please allow a few minutes for the test result.', timeout);
    var checkTestRun = setInterval(function(){
        // check if test is done running
        $.ajax({
            type: "GET",
            url: '/tests/check_test_running',
            data: {test_id: test_id},
            success: function(result, status, xhr) {
                console.log(result);
                if (!result) {
                    clearTimeout(checkTestRun);
                    restore_btn_menu();

                    // open result page in new tab
                    var win = window.open('/results/' + test_id, '_blank');
                    if (win) {
                        // Browser has allowed it to be opened
                        win.focus();
                    } else {
                        // Browser has blocked it
                        alert('Please allow popups for this website');
                    }
                }
            }
        });
    }, 1500);
});


function modalFunction() {
    $('.modal.fade').on('hidden.bs.modal', function () {
        $('.modal.fade').remove();
    });

    $('#selectorType').on('change', function() {
        var selectorType = this.value;
        $('#custom-click-selector').html($('#choose-by-' + selectorType).html());
        $('#custom-click-selector input[name="eq"]').val(0);
    });

    $('select[name="assertionType"]').on('change', function() {
        var assertionType = this.value;
        $('#assertion-condition').html($('#assertion-by-' + assertionType).html());
    });

    $(".modal.fade .chosen-select").chosen();
    $('.modal.fade .chosen-container').css('width', '100%');
}

$(document).on("click", "#generate_code", function(e) {
    $('#dl_code').hide();
    var generate_btn = $('#generate_code');
    generate_btn.html('Generating');
    generate_btn.toggleClass('btn-danger');
    generate_btn.toggleClass('btn-default');

    $.ajax({
        type: "GET",
        url: '/tests/generate_code',
        data: {test_id: test_id},
        success: function(html, status, xhr) {
            if(html != 'ok') {
                alert('Code is generating. Please allow a few minutes and try again.');
            } else {
                $('#dl_code').show();
                $('#dl_code').click();
            }
        },
        complete: function(result, status, xhr) {
            $('#dl_code').show();
            generate_btn.html('Generate Code');
            generate_btn.toggleClass('btn-danger');
            generate_btn.toggleClass('btn-default');
        }
    });
});


