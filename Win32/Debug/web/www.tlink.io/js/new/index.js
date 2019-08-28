var basePath;

var count="",countdown="",btn="";
var nc,token='',sessionId='',sig='',scene='';
$(function()
{
	basePath=$("#basePath").val();
	//导航条切换效果
	$(".pc-a").each(function()
	{  
		$this = $(this);
		if($this[0].href==String(window.location))
		{  

			$(".pc-b").removeClass("pc-b");
			$this.addClass("pc-b");  

		}
	});
	//下拉菜单
	$(".down").mouseenter(function()
	{
		$(this).find(".down-none").show();
	});
	$(".down").mouseleave(function()
	{
		$(this).find(".down-none").hide();
	});
	//演示账号登录
	$("#demoDengLu").on("click", function()
	{
		$("#loginName").val("TLINK");
		$("#pass").val("123123");
		$.ajax({
           type: "POST",
           url: basePath+"/user/login.htm",
           data: {"loginAccount":$("#loginName").val(),"loginPassword":$("#pass").val()},
           success: function (data) {
               var jsonObj = $.parseJSON(data);
			   if ('00' == jsonObj.flag) {
			      window.location.href = jsonObj.url;
			   }else{
			      tooltips(jsonObj.msg);
			      return false;
			   }
           }
       });
	})
	//账号登录
	$("#denglu").on("click", function()
	{
		var name = $("#loginName").val();
		var pass = $("#pass").val();
		if(name == "" || name == null)
		{
			tooltips("请输入账号！");
			return false;
		}else if(pass == "" || pass == null)
		{
			tooltips("请输入密码！");
			return false;
		}
		$.ajax({
           type: "POST",
           url: basePath+"/user/login.htm",
           data: {"loginAccount":name,"loginPassword":pass},
           success: function (data) {
               var jsonObj = $.parseJSON(data);
			   if ('00' == jsonObj.flag) {
			      window.location.href = jsonObj.url;
			   }else{
			      tooltips(jsonObj.msg);
			      return false;
			   }
           }
       });
	})
	/*客服*/
	$(".z-kefu-popu").mousedown(function()
	{
		$(this).parent(".z-kefu").animate(
		{
			right:'0'
		});
	})
	$(".z-kefu").mouseleave(function()
	{
		$(this).animate(
		{
			right:'-160px'
		});
	})
	
	$(".reg-switch").on("click",function(){
		$("#regFlag").val($(this).attr("id"));
	});
	//注册之获取验证码
	onEmailVerification();
	onMobileVerification();
	
	//注册
	$(".pc-user-reg").on("click",function(){
		var regFlag=$("#regFlag").val();
		var email="",emailcode="",mobile="",mobilecode="",Password_1="",Password_2="";
		if(regFlag=="emailFlag"){	//邮箱
		    Password_1 = $.trim($("#emailPwd").val());
   			var ConfirmPassword_1 = $.trim($("#emailAgainPwd").val());
   			email = $.trim($("#email").val());
   			emailcode = $.trim($("#emailCode").val());
   			if("" == email){
   			   tooltips("请输入邮箱！");
   			   return false;
   			}
   			if("" == emailcode){
   			   tooltips("请输入邮箱验证码！");
   			   return false;
   			}
   			if("" == Password_1){
   			  tooltips("请输入密码！");
   			  return false;
   			}
   			if("" == ConfirmPassword_1){
   			  tooltips("请再次输入密码！");
   			  return false;
   			}
   			if(Password_1!=ConfirmPassword_1){
   				tooltips("两次密码输入不一致");
   				return false;
   			}
		}else if(regFlag=="mobileFlag"){	//手机号
			Password_2 = $.trim($("#mobilePwd").val());
   			var ConfirmPassword_2 =  $.trim($("#mobileAgainPwd").val());
   			mobile = $.trim($("#mobile").val());
   			mobilecode = $.trim($("#mobileCode").val());
   			if("" == mobile){
   			   tooltips("请输入手机号码！");
   			   return false;
   			}
   			if("" == mobilecode){
   			   tooltips("请输入手机验证码！");
   			   return false;
   			}
   			if("" == Password_2){
   			  tooltips("请输入密码！");
   			  return false;
   			}
   			if("" == ConfirmPassword_2){
   			  tooltips("请再次输入密码！");
   			  return false;
   			}
   			if(Password_2!=ConfirmPassword_2){
   				tooltips("两次密码输入不一致");
   				return false;
   			}
		}
		 $.ajax({
           type: "POST",
           url: basePath+"/user/registe.htm",
           data: {"email":email,"mobile":mobile,"mobilecode":mobilecode,"emailcode":emailcode,"password1":Password_2,"password2":Password_1},
           success: function (data) {
               var jsonObj = $.parseJSON(data);
			   if ('00' == jsonObj.flag) {
			      window.location.href = jsonObj.url;
			   }else{
			      tooltips(jsonObj.msg);
			   }
            }, error: function(data) {
               tooltips("error:" + data.responseText);
            }
          });
	});
	
	$(".pc-register").on("click",function(){
		 //绑注册
		 getSliderNav("sliderNav","nc_register");
	});
})

/********************滑动块**********************/
function getSliderNav(id,sceneParam){
	 var nc_token = ["FFFF0N00000000006C27", (new Date()).getTime(), Math.random()].join(':');
      var NC_Opt = 
      {
          renderTo: "#"+id,
          appkey: "FFFF0N00000000006C27",
          scene: sceneParam,
          token: nc_token,
          customWidth: 320,
          customHeight: 100,
          trans:{"key1":"code0"},
          elementID: ["usernameID"],
          is_Opt: 0,
          language: "cn",
          isEnabled: true,
          timeout: 3000,
          times:5,
          apimap: {
              // 'analyze': '//a.com/nocaptcha/analyze.jsonp',
              // 'get_captcha': '//b.com/get_captcha/ver3',
              // 'get_captcha': '//pin3.aliyun.com/get_captcha/ver3'
              // 'get_img': '//c.com/get_img',
              // 'checkcode': '//d.com/captcha/checkcode.jsonp',
              // 'umid_Url': '//e.com/security/umscript/3.2.1/um.js',
              // 'uab_Url': '//aeu.alicdn.com/js/uac/909.js',
              // 'umid_serUrl': 'https://g.com/service/um.json'
          },   
          callback: function (data) { 
//              window.console && console.log(nc_token)
//              window.console && console.log(data.csessionid)
//              window.console && console.log(data.sig)
              token=nc_token;
              sessionId=data.csessionid;
              sig=data.sig;
              scene=sceneParam;
          }
      }
 	  nc = new noCaptcha(NC_Opt)
  	  console.log(nc);
      nc.upLang('cn', {
          _startTEXT: "请按住滑块，拖动到最右边",
          _yesTEXT: "验证通过",
          _error300: "哎呀，出错了，点击<a href=\"javascript:__nc.reset()\">刷新</a>再来一次",
          _errorNetwork: "网络不给力，请<a href=\"javascript:__nc.reset()\">点击刷新</a>",
      })
}
/* 选项卡平台链接 */
+function ($) 
{
	"use strict";
	var ITEM_ON = "tab-b";
	var LIST    = "tab-itme"
	var showTab = function(a) 
	{
		var $a = $(a);
		if($a.hasClass(ITEM_ON)) return;
		var href = $a.attr("href");
		if(!/^#/.test(href)) return ;
		$a.siblings("."+ITEM_ON).removeClass(ITEM_ON);
		$a.addClass(ITEM_ON);
		$(href).siblings("."+LIST).removeClass(LIST);
		$(href).addClass(LIST);
	}
	$.showTab = showTab;
	$(document).on("click", ".link-a", function(e) 
	{ 
		e.preventDefault();
		var $a = $(e.currentTarget);
		var href = $a.attr("href");
		if($a.hasClass(ITEM_ON)) return;
		if(!/^#/.test(href)) return;
		showTab($a);
	});
}($);

/* 选项卡通用 */
+function ($) 
{
	"use strict";
	var ITEM_ON = "tab-b";
	var LIST    = "tab-itme"
	var showTab = function(a) 
	{
		var $a = $(a);
		if($a.hasClass(ITEM_ON)) return;
		var href = $a.attr("href");
		if(!/^#/.test(href)) return ;
		$a.siblings("."+ITEM_ON).removeClass(ITEM_ON);
		$a.addClass(ITEM_ON);
		$(href).siblings("."+LIST).removeClass(LIST);
		$(href).addClass(LIST);
	}
	$.showTab = showTab;
	$(document).on("click", ".tab-a", function(e) 
	{ 
		e.preventDefault();
		var $a = $(e.currentTarget);
		var href = $a.attr("href");
		if($a.hasClass(ITEM_ON)) return;
		if(!/^#/.test(href)) return;
		showTab($a);
	});
}($);
// 时间控件
function startTime() 
{  
    var today = new Date();  
    var y = today.getFullYear();  
    var M = today.getMonth()+1;  
    var d = today.getDate();  
    var w = today.getDay();  
    var h = today.getHours();  
    var m = today.getMinutes();  
    var s = today.getSeconds();  
    //var week=['星期天','星期一','星期二','星期三','星期四','星期五','星期六'];  
    // add a zero in front of numbers<10  
    m = checkTime(m);  
    s = checkTime(s);  
    $('.time').html(y+'年'+M+'月'+d+ '日  ' +h+':'+m+':'+ s );//可改变格式  
    t = setTimeout(startTime, 500);  
    function checkTime(i) {  
        if (i < 10) {  
            i = "0" + i;  
        }  
        return i;  
    }  
}
/***************** 提示消息 ********************/
function tooltips(test)
{
	$("#z-tooltips").html(test);
	$("#z-tooltips").show();
	setTimeout(function() 
	{
		$("#z-tooltips").hide(200);
	},3000);
}

function CountDown() {
	$("#"+btn).html("重新获取(" + count + ")"); 
	if (count == 0) { 
		$("#"+btn).html("重新获取验证码"); 
		clearInterval(countdown); 
		if(btn=="ebtn"){	
			onEmailVerification();
		}else{
			onMobileVerification();
		}
	}
	count--; 
} 

//获取邮箱验证码
function onEmailVerification(){
	//邮箱
	$("#ebtn").on("click", function()
	{
        var email=$.trim($("#email").val());
        if(email==null||email == ""){
       		tooltips("请输入邮箱!");
       		return false;
        }
        var regEmail=/^([a-zA-Z0-9.]*[-_]?[a-zA-Z0-9]+)*@([a-zA-Z0-9]*[-_]?[a-zA-Z0-9]+)+[\\.][A-Za-z]{2,3}([\\.][A-Za-z]{2})?$/;
        if(!regEmail.test(email)){
        	tooltips("邮箱格式不正确!");
       		return false;
        }
		count = 60;
		btn="ebtn";
		$(this).unbind("click");	//发送验证码之前先解绑事件，防止重复点击获取验证码
		$.ajax({
 			type:"post",
			url:basePath+"/user/getVerifyCode.htm",
			data:{
				email:email
			},
			success:function(data){
			    var jsonStr = $.parseJSON(data);
			    if("00" == jsonStr.flag){
					if(confirm('发送成功，现在去邮箱查看验证码？')){
						var mail = email.substring(email.indexOf('@') + 1);
						queryEmail.href = "http://mail."+mail; 
						queryEmail.click();
					}
					countdown = setInterval(CountDown, 1000); 
				}else{
					 onEmailVerification();
					 tooltips(jsonStr.msg);
					 return false;
				}
			}
		});
	})
}

//获取手机验证码
function onMobileVerification(){
	//手机号
	$('#mbtn').click(function () {
		
		var mobile=$.trim($("#mobile").val());
		if(mobile == ""){
         	tooltips("请输入手机!");
         	return false;
        }
        var regMobile = /^0?1[3|4|5|7|8|9][0-9]\d{8}$/;
		if(!regMobile.test(mobile)) {
   			tooltips("手机号码格式有误");
   			return false;
		}
		if(token==null||token==''||sessionId==null||sessionId==''||
			sig==null||sig==''||scene==null||scene==''){
			tooltips("请先拖动滑块到最右边");
   			return false;
		}
		count = 60;
		btn="mbtn";
		$(this).unbind("click");	//发送验证码之前先解绑事件，防止重复点击获取验证码
		$.ajax({
			type:"post",
			url:basePath+"/user/getVerifyCode.htm",
			data:{
				mobile:mobile,
				token:token,
                sessionId:sessionId,
                sig:sig,
                scene:scene
			},
			success:function(data){
				var jsonObj = eval('('+data+')');
				var flag = jsonObj.flag;
				nc.reset();	//重置滑动
				token='',sessionId='',sig='';
				if(flag == "00"){
					tooltips("发送成功!");
					countdown = setInterval(CountDown, 1000); 
				}else{
					onMobileVerification();
					tooltips(jsonObj.msg);
					return false;
				}
			}
		});
	});
}