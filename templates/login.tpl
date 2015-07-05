%include header title="تسجيل الدخول", args=args, rq=rq
%from db import *
%from functions import *
%import datetime, random
%setup_all()
%form = True
%rec = False

%if whoLoggedin(rq) != None:
	%if not rq.q.has_key('logout'):
		%raise redirectException(rq.script+"/")
	%end
%end

<h1>تسجيل الدخول</h1>
%ip_address = rq.rhost
%if rq.q.has_key('login'):
	%if rq.q.has_key('username'):
		%error = 0
		%if verify_attempt(ip_address) < 5:
			%if verify_attempt(ip_address) == 3:
				%rec = True
			%end
			%if verify_attempt(ip_address) > 3 and verify_attempt(ip_address) <= 5:
				%rec = True
				%if not rq.q.has_key('recaptcha_challenge_field'):
					<div class="error"><p><strong>خطأ: </strong>لم تكتب الكلمتين الموجودتين في الصورة.</p></div>
					%error = 1
				%else:
					%rec_prive_key = site_info.get_by(name = u"recaptcha_private_key")
					%response = submit_captcha(rq.q.getfirst("recaptcha_challenge_field",""), rq.q.getfirst("recaptcha_response_field",""), rec_prive_key.value, rq.rhost)
					%if not response.is_valid:
						<div class="error"><p><strong>خطأ: </strong>الحروف التي كتبتها مخالفة لصورة الـreCaptcha.</p></div>
						%increase_attempt(ip_address)
						%error = 1
					%end
				%end
			%end
			%if not error:
				%usr = users.get_by(username = escape(rq.q.getfirst('username','')).decode('utf8'))
				%if usr == None:
					<div class="error"><p><strong>خطأ: </strong>اسم مستخدم غير صحيح.</div>
					%increase_attempt(ip_address)
				%elif usr.password != return_hash_sha256(escape(rq.q.getfirst('password',''))).decode('utf8'):
					<div class="error"><p><strong>خطأ: </strong>كلمة السر غير صحيحة.</div>
					%increase_attempt(ip_address)
				%elif not usr.is_active:
					<div class="error"><p><strong>خطأ: </strong>حسابك لم يُفعَّل بعد. يُرجى مراجعة بريدك الإلكتروني للتأكد من وصول رابط التفعيل إليك.</p></div>
				%elif usr.is_banned:
					<div class="error"><p><strong>خطأ: </strong>أنت ممنوع من تسجيل الدخول والمشاركة معنا والسبب:</p>
					<p>{{usr.ban_reason}}</p></div>
				%else:
					%form = False
					%attempt = login_attempts.get_by(ip_address = ip_address.decode('utf8'))
					%attempt.delete()
					%session.commit()
					%is_cookie = 0
					%period = datetime.timedelta(minutes = 30)
					%c_time = 30*60
					%if rq.q.has_key('cookie'):
						%is_cookie = 1
						%period = datetime.timedelta(weeks = 2)
						%c_time = 60*60*24*14
					%end
					%b_time = datetime.datetime.now()
					%e_time = b_time + period
					%while True:
						%s_hash = return_hash_sha256(str(random.randint(000000, 999999)).decode('utf8')).decode('utf8')
						%sn = sessions.get_by(session_hash = s_hash)
						%if sn == None:
							%break
						%end
					%end
					%s = sessions(user = usr, beginnig_time = b_time, ending_time = e_time, session_hash = s_hash, is_cookie = is_cookie, ip_address = rq.rhost.decode('utf8'))
					%session.commit()
					%rq.response.setCookie('egyFantasyCookie', s_hash, c_time)
					%redirect_to = rq.script+'/'
					%if rq.q.has_key('redirect_to'): 
						%redirect_to = rq.q.getfirst('redirect_to','/')
					%end
					<div class="note" id="success"><p>سُجل دخولك بنجاح. مرحبًا بك ضيفًا غزيزًا على موقعنا. نرجو أن تستمتع بإقامتك معنا. سيتم تحويلك إلى حيث كنت، إذا لم يكن متصفحك يدعم التحويل التلقائي: <a href="{{redirect_to}}">اضغط هنا</a> أو يمكنك الذهاب إلى <a href="{{rq.script}}/">الصفحة الرئيسية</a>.</p></div>
					<head>
						<meta http-equiv="refresh" content="5;{{redirect_to}}" />
					</head>
				%end
			%end
		%elif verify_attempt(ip_address) >= 5:
			<div class="error"><p><strong>خطأ: </strong>لقد تعديت عدد مرات تسجيل الدخول المسموح لك بها وهي خمس مرات. حاول مرة أخرى بعد 15 دقيقة.</p></div>
			%form = False
		%end
	%end
%end

%if rq.q.has_key('logout'):
	%if whoLoggedin(rq) != None:
		%s_hash = rq.cookies['egyFantasyCookie'].value.decode('utf8')
		%s = sessions.get_by(session_hash = s_hash)
		%s.ending_time = datetime.datetime.now()
		%session.commit()
		%rq.response.setCookie('egyFantasyCookie', '', 0)
		<div class="note"><p>لقد سُجِّل خروجك بنجاح.</p></div>
	%else:
		<div class="error"><p><strong>خطأ: </strong>لم تقُم بتسجيل الدخول مطلقًا!!</p></div>
	%end
%end

%if form:
	<form id="loginForm" name="loginForm" action="{{rq.script}}/login/" method="POST">
	<input type="hidden" id="login" name="login" value="1" /> 
	<input type="hidden" id="redirect_to" name="redirect_to" value="{{rq.q.getfirst('redirect_to','/') or '/'}}" />
	<table>
		<tr>
			<td><label for="username">اسم المستخدم:</label></td>
			<td><input type="text" id="username" name="username" /></td>
		</tr>
		<tr>
			<td><label for="password">كلمة السر:</label></td>
			<td><input type="password" id="password" name="password" /></td>
		</tr>
		%if rec:
			<tr>
				%rec_pub_key = site_info.get_by(name = u"recaptcha_public_key").value
				<td><label for="recaptcha_challenge_field">reCAPATCHA</label></td>
				<td><div class="ltr">
					<script type="text/javascript"
				    	src="http://www.google.com/recaptcha/api/challenge?k={{rec_pub_key}}">
				    </script>
				    <noscript>
				     	<iframe src="http://www.google.com/recaptcha/api/noscript?k={{rec_pub_key}}"
				        	 height="300" width="500" frameborder="0"></iframe><br>
				     	<textarea name="recaptcha_challenge_field" rows="3" cols="40">
				     	</textarea>
				     	<input type="hidden" name="recaptcha_response_field"
				        	 value="manual_challenge">
				    </noscript></div></td>
			</tr>
		%end
		<tr>
			<td></td>
			<td><input type="checkbox" id="cookie" name="cookie" value="1" />
				<label for="cookie">حفظ البيانات</label></td>
		<tr>
			<td></td>
			<td><input type="submit" class="submit" id="submit" name="submit" value="تسجيل الدخول" /></td>
	</table>
	</form>
%end

%include footer args=args, rq=rq