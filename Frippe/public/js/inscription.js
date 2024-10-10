$(document).ready(function() {
    function visible() {
        if($("input[name = see]").prop("checked")) {
            $("input[name = mdp]").attr('type', 'text');
            $("input[name = conf_mdp]").attr('type', 'text');
        }
        else {
            $("input[name = mdp]").attr('type', 'password');
            $("input[name = conf_mdp]").attr('type', 'password');
        }
    }
    $("#seepwd").change(visible);

    let info = $(".req");
    let mdp = $("input[name = mdp]");
    let mdp2 = $("input[name = conf_mdp]");
    let email = $("input[name = email]");
    function ValidateEmail(mail) {
        var regex = /^([a-zA-Z0-9_\.\-\+])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})+$/;
        return regex.test(mail);
    }
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
        if(mdp.val() != mdp2.val()) {
            bloque = true;
            mdp2.prev().css({"color": "red"});
        }
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