$(".raw-date-container input").change(function() {
    var date_parts = $(this).val().split("-");
    var normalised_id = $(this).attr("id") + "_normalised";
    var normalised = $("#" + normalised_id);
    var year_parts = date_parts[0].split("/");
    if (year_parts.length == 2) {
        var kept = year_parts[0].slice(0, -year_parts[1].length);
        date_parts[0] = kept + year_parts[1];
    }
    normalised.val(date_parts.join("-"));
});
