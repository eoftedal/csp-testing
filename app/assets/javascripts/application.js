// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require_tree .


$(function() {
    $(".results").hide();
    $("#runtests").click(function(evt) {
        evt.preventDefault();
        evt.stopPropagation();
        $(".iframes").text("");
        $(".results").show();
        $(".testcase").remove();
        $("#runner").text("Running...").addClass("running").show();

        setTimeout(function() { runTest(0) }, 100);
    });

    function runTest(id) {
        var testcase = testcases[id];
        if (testcase != null) {
            var tr = $("<tr>").attr("id", "id-" + testcase.id).appendTo($(".results")).addClass("testcase");
            $("<td>").text(testcase.id).appendTo(tr);
            $("<td>").text(testcase.title).appendTo(tr);
            $("<iframe>").attr("src", "/test/load/" + testcase.id).appendTo($(".iframes")).hide();
            setTimeout(function() { runTest(++id) }, 100);
            if (id > 0 && (id % 10 == 0)) loadResults(true);
        } else {
            setTimeout(function() { loadResults(true, false) }, 1000);
            setTimeout(function() { loadResults(true, true) }, 5000);
            setTimeout(function() { loadResults(false, true) }, 15000);
        }
    }
    function loadResults(nofail, finishResults) {
        $.getJSON("/test/results?_=" + (new Date()).getTime()).success(function(results) {
            for (var i in results) {
                $("#id-" + i).removeClass("success").removeClass("fail").addClass(results[i] ? "success" : (nofail ? "" : "fail"));
            }
            if (!finishResults) {
                finishResults = $(".success").length == testcases.length;
            }

            if (finishResults) {
                $("#runner").removeClass("running").text("Results: (" + $(".success").length  + "/" + testcases.length +  ")");
            } else {
                $("#runner").text("Running (" + $(".success").length  + "/" + testcases.length +  ")...");
            }
        });
    }
});