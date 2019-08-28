$(function() {
    var LEFT_NUM = 30; //重新获取验证码间隔时间

    var EMAIL_EXP = /^(\w)+(\.\w+)*@(\w)+((\.\w+)+)$/;

    var $loginDialogForm = $("#loginDialogForm");
    var $registeDialogForm = $("#registeDialogForm");
    var $loginDialogFormBtn = $("#loginDialogFormBtn");
    var $registeDialogFormBtn = $("#registeDialogFormBtn");
    var $account = $loginDialogForm.find('[name="loginAccount"]');
    var $pswd = $loginDialogForm.find('[name="loginPassword"]')
    var $userName = $registeDialogForm.find('[name="userName"]');
    var $password = $registeDialogForm.find('[name="password"]');
    var $verifyBy = $registeDialogForm.find('[name="verifyBy"]');
    var $verifyCode = $registeDialogForm.find('[name="verifyCode"]');

    var $verify = $("#verify");
    var $getVerifyBtn = $("#getVerifyBtn");

    $loginDialogFormBtn.bind('click', function() {
    	if($account.val() == ""){
    		$account.focus();
    		return;
    	}
    	if($pswd.val() == ""){
    		$pswd.focus();
    		return;
    	}
 
        $.post($loginDialogForm.attr('action'),$loginDialogForm.serialize(),function(data){
        	var obj = JSON.parse(data);
        	if(obj.flag == "00"){
        		window.location = obj.redirectUrl;
        	}else if(obj.flag == "01"){            
                $("#loginMsg").empty();
                $("#loginMsg").append($("<div>").addClass('alert alert-danger data-dismissible fade in').text(obj.msg));
        	}else if(obj.flag == "02"){
        		window.location = obj.redirectUrl + "?userName=" + obj.userName;
        	}
        });

    });
    $registeDialogFormBtn.bind('click', function() {
        if ($userName.val() == "" || $userName.val().length < 3 || $userName.val().length > 18) {
            $userName.focus().parent().addClass('has-error');
            return;
        } else if ($password.val() == "" || $password.val().length < 6 || $password.val().length > 32) {
            $password.focus().parent().addClass('has-error');
            return;
        }
        if ($verifyBy.val() == 1) {
            var $email = $registeDialogForm.find('[name="userEmail"]');
            if ($email.val() == "") {
                $email.focus().parent().addClass('has-error');
                return;
            }
        } else if ($verifyBy.val() == 0) {
            var $phone = $registeDialogForm.find('[name="userPhone"]');
            if ($phone.val() == "") {
                $phone.focus().parent().addClass('has-error');
                return;
            }
        }
        if ($verifyCode.val() == "") {
            $verifyCode.focus().parent().addClass('has-error');
            return;
        }

        $.post($registeDialogForm.attr('action'),$registeDialogForm.serialize(),function(data){
            var obj = JSON.parse(data);
            if(obj.flag == "00"){
                window.location = obj.redirectUrl;
            }else if(obj.flag == "01"){
                $("#registeMsg").empty();
                $("#registeMsg").append($("<div>").addClass('alert alert-danger data-dismissible fade in').text(obj.msg));
            }
        });
    });
    $verifyBy.bind("change", function() {
        var verifyBy = $(this).val();
        if (verifyBy == 0) { //手机验证
            $verify.empty();
            $verify.append($("<label>").addClass("sr-only").attr("for", "userPhone").text("手机号码"))
                .append($("<input>").addClass("form-control").attr({
                    "name": "userPhone",
                    "type": "text",
                    "maxLength": 11,
                    "placeholder": "手机号码"
                }).bind('keyup', changeBtnState));
        } else if (verifyBy == 1) { //邮箱验证
            $verify.empty();
            $verify.append($("<label>").addClass("sr-only").attr("for", "userEmail").text("邮箱"))
                .append($("<input>").addClass("form-control").attr({
                    "name": "userEmail",
                    "type": "email",
                    "placeholder": "邮箱"
                }).bind('keyup', changeBtnState));
        }
        $getVerifyBtn.addClass('disabled');
    });
    $registeDialogForm.find('[name="userEmail"]').bind('keyup', changeBtnState);

    $getVerifyBtn.click(function() {
        $getVerifyBtn.addClass('disabled');

        var $email = $registeDialogForm.find('[name="userEmail"]');

        if(!$userName.val() || $userName.val() == ""){
            $userName.focus().parent().addClass('has-error');
            return;
        }

        $verifyBy.addClass('disabled');
        $email.attr("disabled", "disabled");

        var num = LEFT_NUM;
        $getVerifyBtn.text("重新获取(" + num + "秒)");

        var leftTimeId = setTimeout(leftTime, 1000);

        function leftTime() {
            clearTimeout(leftTimeId);
            $getVerifyBtn.text("重新获取(" + (num--) + "秒)");
            if (num >= 0) {
                leftTimeId = setTimeout(leftTime, 1000);
            }else{
                $getVerifyBtn.text("获取验证码");
                $getVerifyBtn.removeClass('disabled');
                $email.removeAttr('disabled');
            }
        }

        $.getJSON("user/getVerifyCode.htm", {
            email: $email.val(),
            userName: $userName.val()
        }, function(data) {
            if (data.flag == "00") {
                $("#afterVerify").append($("<a>").attr({
                    href:"http://" + getEmialUrl($email.val()),
                    target:"_blank"
                }).text("快速登录邮箱")).append($("<i>").addClass("glyphicon").addClass("glyphicon-log-in"));
            } else {
                $("#afterVerify").append(data.msg);
            }
        })
    })

    function changeBtnState() {
        var value = $(this).val();
        $(this).parent().removeClass('has-error');
        if (value == "") {
            $getVerifyBtn.addClass('disabled');
        } else {
            if (!EMAIL_EXP.test(value)) {
                $getVerifyBtn.addClass('disabled');
                return;
            }
            $("#afterVerify").empty();
            $getVerifyBtn.removeClass('disabled');
        }
    }

    function getEmialUrl(email) {
        subfix = email.split('@')[1];
        subfix = subfix.toLowerCase();
        if (subfix == '163.com') {
            return 'mail.163.com';
        } else if (subfix == 'vip.163.com') {
            return 'vip.163.com';
        } else if (subfix == '126.com') {
            return 'mail.126.com';
        } else if (subfix == 'qq.com' || subfix == 'vip.qq.com' || subfix == 'foxmail.com') {
            return 'mail.qq.com';
        } else if (subfix == 'gmail.com') {
            return 'mail.google.com';
        } else if (subfix == 'sohu.com') {
            return 'mail.sohu.com';
        } else if (subfix == 'tom.com') {
            return 'mail.tom.com';
        } else if (subfix == 'vip.sina.com') {
            return 'vip.sina.com';
        } else if (subfix == 'sina.com.cn' || subfix == 'sina.com') {
            return 'mail.sina.com.cn';
        } else if (subfix == 'tom.com') {
            return 'mail.tom.com';
        } else if (subfix == 'yahoo.com.cn' || subfix == 'yahoo.cn') {
            return 'mail.cn.yahoo.com';
        } else if (subfix == 'tom.com') {
            return 'mail.tom.com';
        } else if (subfix == 'yeah.net') {
            return 'www.yeah.net';
        } else if (subfix == '21cn.com') {
            return 'mail.21cn.com';
        } else if (subfix == 'hotmail.com') {
            return 'www.hotmail.com';
        } else if (subfix == 'sogou.com') {
            return 'mail.sogou.com';
        } else if (subfix == '188.com') {
            return 'www.188.com';
        } else if (subfix == '139.com') {
            return 'mail.10086.cn';
        } else if (subfix == '189.cn') {
            return 'webmail15.189.cn/webmail';
        } else if (subfix == 'wo.com.cn') {
            return 'mail.wo.com.cn/smsmail';
        } else if (subfix == '139.com') {
            return 'mail.10086.cn';
        } else {
            return '';
        }
    }
});
