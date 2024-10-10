$(document).ready(function() {
    let info = $(".req");
    function ValidateEmail(mail) {
        var regex = /^([a-zA-Z0-9_\.\-\+])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})+$/;
        return regex.test(mail);
    }

    let email = $("input[name = email]");
    function incomplete() {
        let bloque = false;
        info.each(function() {
            if(!$(this).val()) {
                bloque = true;
                $(this).prev().css({"color": "red"});
            }
            else {
                $(this).prev().css({"color": "black"});
            }
        });
        if(!ValidateEmail(email.val())) {
            bloque = true;
            email.prev().css({"color": "red"});
        }
        if(bloque) {
            $("button[name = go]").attr('disabled', true);
        }
        else {
            $("button[name = go]").removeAttr('disabled');
        }
    }
    info.keyup(incomplete);
})