// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.


function showmore(id,btid) {
    if ($("#" + btid).text() == "View Less") {
        $("#" + btid).html('View More');
        $("#" + id).css("display", "none");
    }
    else {
        $("#" + btid).html('View Less');
        $("#" + id).css("display", "block");
    }

}
