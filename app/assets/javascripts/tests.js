var testUrl = window.location.pathname;
var sessionId = '';


$(document).on('turbolinks:load', function() {
var test_id = $("#page_info").data('test');

$('#startRecording').click(function() {
    testUrl = window.location.pathname;
    sessionId = '';

    // get the session ID
    $.ajax({
        type: "GET",
        url: '/tests/generateSession',
        dataType: "text",
        data: {test_id: test_id},
        success: function(result, status, xhr) {
            sessionId = result;
            $('#notice').html('All your activities on Chrome will be recorded. Please make sure chrome extension is intalled.');

            // activate the Chrome Plugin
            window.postMessage({ type: "FROM_PAGE", session_id: sessionId }, "*");

            // poll extension for new events every seconds
            // var extensionId = "lekchccmedapfjjoaanmoaoekpiniknc";
            //
            // chrome.runtime.sendMessage(extensionId, {type: 'query_step'},
            //     function(response) {
            //         console.log(response);
            //     });

            location.reload();
        }
    });
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

$(document).on("click", ".delete-step", function(e) {
    var step_id = $(this).closest('.step-list-item').data('step');
    var list_item = $(this).parent();

    if(confirm('Are you sure you would like to delete this comment?')) {
        $.ajax({
            type: "GET",
            url: '/step/delete_step',
            dataType: "text",
            data: {step_id: step_id},
            success: function(result, status, xhr) {
                list_item.remove();
            }
        });
    }
});

// show the input field when click on dotted span
$(document).on("click", ".editable.selector", function(e) {
    var editDiv = $(this).next();
    editDiv.toggle();
});

// edit non-selector spans
$(document).on("click", ".editable", function(e) {
    if ($(this).hasClass('selector'))
        return;

    var value = $(this).html();
    var inputCombo = $("#copyable .input-combo")[0].outerHTML;
    $(this).after(inputCombo);
    var insertedCombo = $(this).next();
    insertedCombo.find('input').eq(0).val(value);
    insertedCombo.css('display', 'inline-block');
    // set size relative to existing value
    // insertedCombo.css('width', value.length + 5);
    $(this).hide();
});

/*
    most logics DO NOT apply to click events
    1. all editable Span are followed by edit Div
 */

// discard data and show the dotted span
$(document).on("click", ".input-combo .glyphicon-remove", function(e) {
    var editableSpan = $(this).parents().prev();
    $(this).parent().remove();
    editableSpan.show();
    $('#validation_err').hide();
});





/*
    save editable fields by clicking on glyphicon-ok symbols
 */

// save editable values
$(document).on("click", ".glyphicon-ok", function(e) {
    var step_id = $(this).closest('.step-list-item').data('step');

    // find out which field is this. It's always preceded by an editable span
    var editableSpan = $(this).parent().prev('.editable');
    var glyp = $(this);

    // save wait time
    if (editableSpan.hasClass('wait')) {
        var wait = glyp.prev().val();

        $.ajax({
            type: "GET",
            url: '/step/change_wait',
            dataType: "json",
            data: {step_id: step_id, wait: wait},
            success: function(result, status, xhr) {
                glyp.parent().prev().show();
                glyp.parent().prev().html(wait);
                glyp.parent().hide();
            },
            error: function(html) {
                var errors = html.responseJSON;
                $('#validation_err').show();
                $('#validation_err').html(errors[0]);
            }
        });
    } else if (editableSpan.hasClass('webpage')) {
        var webpage = $(this).prev().val();

        $.ajax({
            type: "GET",
            url: '/step/change_webpage',
            dataType: "json",
            data: {step_id: step_id, webpage: webpage},
            success: function(result, status, xhr) {
                glyp.parent().prev().show();
                glyp.parent().prev().html(webpage);
                glyp.parent().hide();
            },
            error: function(html) {
                $('#validation_err').show();
                $('#validation_err').html('Url cannot be empty');
            }
        });
    } else if (editableSpan.hasClass('scrollTop')) {

    } else if (editableSpan.hasClass('scrollLeft')) {

    }
});




/*
    visual effect
 */
$(".selector-select li").hover(
    function() {
        $( this ).css('font-size', '20px');
    }, function() {
        $( this ).css('font-size', '15px');
    }
);


$("body").on('mouseenter', '.step-list-item', function() {
    $(this).find('.visible-hover').show();
}).on('mouseleave', '.step-list-item', function() {
    $('.visible-hover').hide();
});


/*
    CLICK LOGICS
 */

// show index input when user click on classes
$(document).on("click", ".step-classes .step-class", function(e) {
    $('.step-classes .classes-select').remove(); // remove all opening index input

    var classSelectDiv = $('#copyable .classes-select')[0].outerHTML;
    $(this).after(classSelectDiv);
    $(this).next().show();

    // default index is 1
    var insertedCombo = $(this).next();
    insertedCombo.find('input').eq(0).val($(this).html() + ' : eq( 1 )');
});

// user cancel class picking
$(document).on("click", ".step-classes .glyphicon-remove", function(e) {
    $(this).closest('.classes-select').remove();
});



/*
    TEST PARAMS
 */

var test_param_count = 0; //initlal text box count

$("#add-test-params").click(function(e){ //on add input button click
    e.preventDefault();
    test_param_count++; //text box increment
    var html = $('#copyable .empty-test-params')[0].outerHTML;
    $('#test-params-input-list').append(html);
    $('#submit-test-params').show();
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

$("#submit-test-params").on("click", function(e){ //user click on remove text
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
        },
        error: function(result, status, xhr) {
            alert('Sorry, we could not add a parameter at this time.');
        }
    });
});

/*
    STEP HEADERS AND PARAMS
 */

$(".step-list-item .hover-edit-btn").on("click", function(e) { // add more headers
    var step_id = $(this).closest('.step-list-item').data('step');

    $.ajax({
        type: "GET",
        url: '/step/edit_view',
        data: {step_id: step_id},
        success: function(html, status, xhr) {
            $('body').append(html);
            $('.modal.fade').modal();
            modalFunction();
        },
        error: function(result, status, xhr) {
            alert('Sorry, we could not remove a parameter at this time.');
        }
    });
});

function modalFunction() {
    $('.modal.fade').on('hidden.bs.modal', function () {
        $('.modal.fade').remove();
    });

    $('#selectorType').on('change', function() {
        var selectorType = this.value;
        $('#custom-click-selector').html($('#choose-by-' + selectorType).html());
        $('#custom-click-selector input[name="index"]').val(1);
    });

    $(".chosen-select").chosen();
    $('.chosen-container').css('width', '100%');
}

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

$(document).on("click", "#edit-pageload-form .submit", function(e) {
    var step_id = $(this).closest('.modal.fade').data('step');

    $.ajax({
        type: "POST",
        url: '/step/save_pageload',
        data: {step_id: step_id,
            form: $('#edit-pageload-form').serialize()
        },
        success: function(html, status, xhr) {
        },
        error: function(result, status, xhr) {
            alert('Sorry, we could not step data at this time.');
        }
    });

    $('.modal.fade').modal('hide');
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
        },
        error: function(result, status, xhr) {
            alert('Sorry, we could not step data at this time.');
        }
    });

    $('.modal.fade').modal('hide');
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
    ".empty-pageload-params .empty-pageload-params," +
    " .empty-extract-param .remove-extract-param", function(e) {
    $(this).parent().remove();
});

$(document).on("click", ".save-click-step", function(e) {
    var step_id = $(this).closest('.modal.fade').data('step');
    var form = $(this).closest('form');

    $.ajax({
        type: "POST",
        url: '/step/change_selector',
        data: {step_id: step_id,
            form: form.serialize()
        },
        success: function(html, status, xhr) {
            $('.modal.fade').modal('hide');
            $("#step-list [data-step='" + step_id + "']").replaceWith(html);
        },
        error: function(result, status, xhr) {
            alert('Sorry, we could not save step data at this time.');
        }
    });
});

$(document).on("click", ".add-step-after, #addNewStep", function(e) {
    var step_id = $(this).closest('.step-list-item').data('step');

    $.ajax({
        type: "GET",
        url: '/step/add_step_view',
        data: {step_id: step_id},
        success: function(html, status, xhr) {
            $('body').append(html);
            $('.modal.fade').modal();
            modalFunction();
        },
        error: function(result, status, xhr) {
            alert('Sorry, we could not remove a parameter at this time.');
        }
    });
});

$(document).on("click", ".add-new-step", function(e) {
    var step_id = $(this).closest('.modal.fade').data('step');
    var form = $(this).closest('form');

    $.ajax({
        type: "POST",
        url: '/step/save_new_step',
        data: {step_id: step_id, test_id: test_id,
            form: form.serialize()
        },
        success: function(html, status, xhr) {
            $('.modal.fade').modal('hide');

            // append the new step right after
            if (step_id)
                $(".step-list-item[data-step='" + step_id + "']").after(html);
            else
                $("#step-list").append(html);
        },
        error: function(result, status, xhr) {
            alert('Sorry, we could not save step data at this time.');
        }
    });
});

$(document).on("click", "#add-assertion", function(e) {
    $.ajax({
        type: "GET",
        url: '/tests/newAssertionView',
        data: {test_id: test_id},
        success: function(html, status, xhr) {
            $('body').append(html);
            $('.modal.fade').modal();
            modalFunction();
        },
        error: function(result, status, xhr) {
            alert('Sorry, we could not remove a parameter at this time.');
        }
    });
});

$(document).on("click", ".add-new-assertion", function(e) {
    var form = $(this).closest('form');

    $.ajax({
        type: "GET",
        url: '/tests/addAssertion',
        data: {test_id: test_id, form: form.serialize()},
        success: function(html, status, xhr) {
            $('#assertion-list').prepend(html);
            $('.modal.fade').modal('hide');
        },
        error: function(result, status, xhr) {
            alert('Assertion body cannot be blank.');
        }
    });
});

$(document).on("click", ".remove-assertion", function(e) {
    var assertionLabel = $(this).closest('.assertion');
    var assertion_id = assertionLabel.data('id');

    $.ajax({
        type: "GET",
        url: '/tests/removeAssertion',
        data: {assertion_id: assertion_id, test_id: test_id},
        success: function(html, status, xhr) {
            $('.modal.fade').modal('hide');
            assertionLabel.remove();
        },
        error: function(result, status, xhr) {
            alert('Sorry, we could not remove the assertion at this time.');
        }
    });
});

$(document).on("click", ".disable-assertion", function(e) {
    var assertionLabel = $(this).closest('.assertion');
    var assertion_id = assertionLabel.data('id');

    $.ajax({
        type: "GET",
        url: '/tests/disableAssertion',
        data: {assertion_id: assertion_id, test_id: test_id},
        success: function(html, status, xhr) {
            $('.modal.fade').modal('hide');
        },
        error: function(result, status, xhr) {
            alert('Sorry, we could not remove a parameter at this time.');
        }
    });
});



});
