var counter = 0

function setup(filename) {
    counter = $("#formContainer form").length
    var width = $("#picture").width()
    var ratio = 800/width
    console.log(ratio)
    var multiplier = 1/ratio;
    var border = undefined;
    $("#picture").width(width*ratio)
    $("#imageContainer .frame").each(function( index ) {
        $(this).width($(this).width()*ratio);
        $(this).height($(this).height()*ratio);
        var top = $(this).css("top").replace("px", "")
        var left = $(this).css("left").replace("px", "")
        
        console.log("left:" + left);
        $(this).css('left', left * ratio + "px");
        $(this).css('top', top * ratio + "px");
      });

    $("#imageContainer").mousemove(function (event) {
        if (border != undefined) {
            var parentOffset = $(this).parent().offset();
            var relX = event.pageX - parentOffset.left;
            var relY = event.pageY - parentOffset.top;
            var x = Math.round((event.pageX - $(this).offset().left));
            var y = Math.round((event.pageY - $(this).offset().top));
            
            border.height(y - border.position().top);
            border.width(x - border.position().left);
        }
    });
    $("#imageContainer").mousedown(function (event) {
        counter++;
        var parentOffset = $(this).parent().offset();
        var relX = event.pageX - parentOffset.left;
        var relY = event.pageY - parentOffset.top;
        var x = Math.round((event.pageX - $(this).offset().left));
        var y = Math.round((event.pageY - $(this).offset().top));
        console.log(x, y);
        border = $("<div/>")
        border.addClass("frame absolute");
        border.css({top: y, left: x});
        $("#imageContainer").append(border)
    });
    $("#imageContainer").mouseup(function (event) {
        var left = Math.round(border.position().left * multiplier);
        var top = Math.round(border.position().top * multiplier);
        var width = Math.round(border.width() * multiplier);
        var height = Math.round(border.height() * multiplier);
        //console.log("captured object on image; left: " + border.position().left + "px; top: " + border.position().top + "px; width: "+ border.width() + "px; height: "+ border.height() + "px;");
        console.log("captured object on image; left: " + left + "px; top: " + top + "px; width: "+ width + "px; height: "+ height + "px;");
        
        var number = $("<div/>")
        number.html(counter);
        number.addClass("counter");
        border.append(number);
        border = undefined;
        makeForm(counter, top, left, width, height, filename)
    });
}

function makeForm(counter, top, left, width, height, filename) {
    var form = $('<form method="post"/>');
    var index = $("<div/>");
    index.addClass("counter");
    index.css({float: "left"});
    index.html(counter);
    var input = $('<input class="form-control-sm" type="text" name="label" placeholder="label">');
    form.append(input);
    var submit = $('<input type="submit" class="btn btn-sm btn-primary" value="Save"/>');
    form.append(submit);
    form.append(index);
    addHiddenInput(form, "frame", '{"top":'+top+',"left":'+left+',"width":'+width+',"height":'+height+'}');
    addHiddenInput(form, "filename", filename);
    $("#formContainer").append(form);
}

function addHiddenInput(form, name, value) {
    var input = $('<input type="hidden" name="'+name+'" value=\''+value+'\'/>');
    form.append(input);
}
