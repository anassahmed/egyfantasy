<!DOCTYPE HTML>
<html>
	%from functions import *
	<head>
		<title>{{title or "لا عنوان"}} | الخيال المصري</title>
		<meta http-equiv="content-type" content="text/html; charset=utf-8" />
		%try:
			%d = description
		%except NameError:
			%d = 'موقع لمحاكاة الحاية السياسية بعد الثورة في مصر'
		%end
		<meta name="description" content="{{d}}" />
		<meta name="keywords" content="مصر, الثورة, 52 يناير, أحزاب, سياسة, حكومة, دستور, انتخابات, حكومة" />
		<link rel="stylesheet" type="text/css" href="{{rq.script}}/css/stylesheet.css" />
		<link rel="stylesheet" type="text/css" href="{{rq.script}}/css/nivo-slider.css" />
		<link rel="stylesheet" type="text/css" href="{{rq.script}}/css/slider.css" />
		<script type="text/javascript" src="{{rq.script}}/scripts/jquery-1.5.1.min.js"></script>
		<script type="text/javascript" src="{{rq.script}}/scripts/jquery.nivo.slider.js"></script>
		<script type="text/javascript" src="{{rq.script}}/scripts/jquery.urlshortener.js"></script>
		<script type="text/javascript" src="{{rq.script}}/scripts/share.js"></script>
		
		<script type="text/javascript">
			$(document).ready(function() {
				$("#m_slide_img").attr('style','');
				$("#slider").nivoSlider({
					effect: 'fade', 
					pauseOnHover: false, 
					directionNavHide:false});
			});
		</script>
	</head>
	<body>
		<div id="wrap">
			<div id="header">
				<div id="nav">
					<div id="mainLinks">
						<a href="{{rq.script}}/"><img src="{{rq.script}}/images/home.png" align="top" width="20" /> الرئيسية</a>
						<a href="{{rq.script}}/blog/"><img src="{{rq.script}}/images/blog.png" align="top" width="20" /> المدونة</a>
						%if whoLoggedin(rq) == None:
						<a href="{{rq.script}}/register/"><img src="{{rq.script}}/images/register.png" align="top" width="20" />التسجيل</a>
						<a href="{{rq.script}}/login/" id="login-no-js"><img src="{{rq.script}}/images/login.png" align="top" width="20" /> تسجيل الدخول</a>
						%end
						%if whoLoggedin(rq) != None:
						<a href="{{rq.script}}/user/{{whoLoggedin(rq).username}}/" id="personal-page-no-js">الشخصية</a>
						<a href="{{rq.script}}/user/{{whoLoggedin(rq).username}}/notifications/" id="notifications-no-js">التنبيهات</a>
						<a href="{{rq.script}}/user/{{whoLoggedin(rq).username}}/mail/" id="mail-no-js">الرسائل</a>
						<a href="{{rq.script}}/user/{{whoLoggedin(rq).username}}/settings/" id="settings-no-js">الإعدادات</a>
						<a href="{{rq.script}}/login?logout=1" id="logout-no-js">خروج</a>
						%end
					</div><!-- #mainLinks -->
					%if whoLoggedin(rq) == None:
					%if title != "التسجيل":
					%if title != "تسجيل الدخول":
						<div id="loginBox" class="hidden">
							<form id="loginForm" name="loginForm" action="{{rq.script}}/login/" method="POST">
								<script type="text/javascript">
								$(document).ready(function() {
									$("#login-no-js").hide();
									$("#loginBox").show();
									$("#user_label").click(function() {
										$('#user_label img').attr('src', '{{rq.script}}/images/login_user_active.png');
										$('#pass_label img').attr('src', '{{rq.script}}/images/login_pass.png');
										$("#password").hide();
										$('#username').fadeIn("slow");
									})
									$("#pass_label").click(function() {
										$('#pass_label img').attr('src', '{{rq.script}}/images/login_pass_active.png');
										$('#user_label img').attr('src', '{{rq.script}}/images/login_user.png');
										$("#username").hide();
										$('#password').fadeIn("slow");
									})
									$("#user_label").click()
									$("#username").keypress(function (e) {
									    if (e.keyCode == 9) {
									        $("#pass_label").click();
									        $("#password").focus();
									    }
									});
									$("#password").keypress(function (e) {
									    if (e.keyCode == 9) {
									        $("#user_label").click();
									        $("#username").focus();
									    }
									});
								})
								</script>
								<input type="hidden" id="login" name="login" value="1" />
								<label for="username" id="user_label" title="اسم المستخدم"><img src="{{rq.script}}/images/login_user.png" /></label>
								<label for="password" id="pass_label" title="كلمة السر"><img src="{{rq.script}}/images/login_pass.png" /></label>
								<input type="text" id="username" name="username" tabindex="1" />
								<input type="password" id="password" name="password" tabindex="2" />
								<input type="checkbox" id="cookie" name="cookie" value="1" tabindex="3" />
								<label for="cookie">حفظ البيانات</label>
								%if rq.qs != "":
									%qs = "?"+rq.qs
								%else:
									%qs = ""
								%end
								<input type="hidden" id="redirect_to" name="redirect_to" value="{{rq.script+rq.uri+qs}}" />
								<input type="submit" class="submit" id="submit" name="submit" value="لُج" />
							</form>
						</div>
					%end
					%end
					%end
					%if whoLoggedin(rq) != None:
						%increaseSession(rq)
					%end
				</div><!-- #nav -->
				<div id="slider" class="nivoSlider">
					<img style="display: block;" src="{{rq.script}}/images/1-logo.png" id="m_slide_img" />
					<img src="{{rq.script}}/images/2-logo.png" />
					<img src="{{rq.script}}/images/3-logo.png" />
					<img src="{{rq.script}}/images/4-logo.png" />
					<img src="{{rq.script}}/images/5-logo.png" />
				</div><!-- #slider -->
			</div><!-- #header -->
			<a href="{{rq.script}}/"><img src="{{rq.script}}/images/logo.png" id="logo" alt="الخيال المصري" /></a>
			<div id="content">