// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.


    function showmore(id) {
        if ($("#vmbutton").text() == "View Less") {
            $("#vmbutton").html('View More');
            $("#" + id).css("display", "block");
        }
        else {
            $("#vmbutton").html('View Less');
            $("#" + id).css("display", "none");
        }

    }
