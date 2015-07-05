%include header title="التسجيل", rq=rq, args=args

%from db import *
%from functions import *

%setup_all()

%form = True
%username = ""
%first_name = ""
%second_name = ""
%email = ""
%state = ""
%description = ""

%if whoLoggedin(rq) != None:
	%raise redirectException(rq.script+"/")
%end

<h1>بيانات التسجيل</h1>
%if rq.q.has_key('username'):
	%data = [rq.q.getfirst('username',''), rq.q.getfirst('password',''), rq.q.getfirst('password_again',''),rq.q.getfirst('first_name',''), rq.q.getfirst('second_name',''),rq.q.getfirst('email',''), rq.q.getfirst('state',''), rq.q.getfirst('description',''), rq.q.getfirst('recaptcha_challenge_field',''), rq.q.getfirst('recaptcha_response_field','')]
	%n = 0
	%for i in data:
		%data[n] = escape(i, quote=True).decode('utf8')
		%n += 1
	%end
	%error = 0
	%for i in data:
		%if i == "" or i == None:
			<div class="error"><p><strong>خطأ: </strong>إحدى البيانات تُركت فارغة.</p></div>
			%error = 1
			%break
		%end
	%end
	%if not error:
		%rec_prive_key = site_info.get_by(name = u"recaptcha_private_key")
		%response = submit_captcha(data[8], data[9], rec_prive_key.value, rq.rhost)
		%if not response.is_valid:
			<div class="error"><p><strong>خطأ: </strong>الحروف التي كتبتها مخالفة لصورة الـreCaptcha.</p></div>
			%error = 1
		%end
	%end
	%if not error:
		%if not is_username_valide(data[0]):
			<div class="error"><p><strong>خطأ: </strong>يحتوي اسم المستخدم على حروف ممنوعة.</p></div>
			%error = 1
		%end
		%usr = users.get_by(username = data[0])
		%if usr != None:
			<div class="error"><p><strong>خطأ: </strong>اسم المستخدم غير متاح. من فضلك اختر اسمًا آخر.</p></div>
			%error = 1
		%end
		%if len(data[1]) < 6:
			<div class="error"><p><strong>خطأ: </strong>كلمة السر أقل من 6 حروف.</p></div>
			%error = 1
		%end
		%if data[1] != data[2]:
			<div class="error"><p><strong>خطأ: </strong>كلمتي السر غير متطابقتين.</p></div>
			%error = 1
		%end
		%atpos = data[5].rfind("@")
		%dotpos = data[5].rfind(".")
		%if (atpos < 1) or ((dotpos-atpos) < 2):
			<div class="error"><p><strong>خطأ: </strong>البريد الإلكتروني غير صحيح.</p></div>
			%error = 1
		%end
		%usr = users.get_by(email = data[5])
		%if usr != None:
			<div class="error"><p><strong>خطأ: </strong>هذا البريد الإلكتروني مستخدم من قبل. إذا كنت قد نسيت كلمة السر فتوجه لصفحة الدخول واضغط على الزر "نسيت كلمة السر"</p></div>
			%error = 1
		%end
	%end
	%if error:
		%username = data[0]
		%first_name = data[3]
		%second_name = data[4]
		%email = data[5]
		%state = data[6]
		%description = data[7]
	%end
	%if not error:
		%random_hash = get_active_hash()
		%new_user = users(username = data[0], password = return_hash_sha256(data[1]), first_name = data[3], second_name = data[4], email = data[5], state = data[6], description = data[7], is_active = 0, active_hash = random_hash)
		%session.commit()
		%send_activate_msg(new_user)

		%form = False
		<div class="note"><p>لقد سُجِّلت بنجاح. ستستقبل رسالة على بريدك الإلكتروني بها رابط تفعيل عضويتك.</p></div>
	%end
%end
%if form:
<div class="note"><p><strong>ملحوظة هامة: </strong>&nbsp;&nbsp;<em>جميع المعلومات أدناه مطلوبة.</em></p></div>
<form id="registerForm" name="registerForm" action="{{rq.script}}/register/" method="POST">
	<table>
		<tr>
			<td><label for="username">اسم المستخدم:</label></td>
			<td><input type="text" id="username" name="username" value="{{username}}" /></td>
			<td class="instructions">يجب أن لا يحتوي اسم المستخدم على غير الحروف الإنجليزية الصغيرة والكبيرة والأرقام، وأن لا يزيد عدد أحرفه عن 20 حرفًا.</td>
		</tr>
		<tr>
			<td><label for="password">كلمة السر:</label></td>
			<td><input type="password" id="password" name="password" /></td>
			<td class="instructions">يجب أن تكون كلمة السر أكثر من 6 حروف، وأن تختلط الحروف بالأرقام.</td>
		</tr>
		<tr>
			<td><label for="password_again">إعادة كلمة السر:</td>
			<td><input type="password" id="password_again" name="password_again" /></td>
			<td class="instructions">تأكيدًا على حفظك لكلمة السر.</td>
		</tr>
		<tr>
			<td><label for="first_name">الاسم الأول:</label></td>
			<td><input type="text" id="first_name" name="first_name" value="{{first_name}}" /></td>
			<td class="instructions">سيستخدم هذا الاسم للعرض في صفحتك الشخصية والتعليقات وخلافه.</td>
		</tr>
		<tr>
			<td><label for="second_name">الاسم الأخير:</label></td>
			<td><input type="text" id="second_name" name="second_name" value="{{second_name}}" /></td>
			<td class="instructions">سيستخدم هذا الاسم للعرض في صفحتك الشخصية والتعليقات وخلافه.</td>
		</tr>
		<tr>
			<td><label for="email">البريد الإلكتروني:</label></td>
			<td><input type="text" id="email" name="email" value="{{email}}" /></td>
			<td class="instructions">سيرسل رابط التفعيل إليه، لذا يجب أن يكون حقيقيًا.</td>
		</tr>
		<tr>
			<td><label for="state">المحافظة:</label></td>
			<td>
				<select id="state" name="state">
					<option value="القاهرة">القاهرة</option>
					<option value="الجيزة">الجيزة</option>
					<option value="القليوبية">القليوبية</option>
					<option value="الإسكندرية">الإسكندرية</option>
					<option value="السويس">السويس</option>
					<option value="الإسماعيليهة">الإسماعيلية</option>
					<option value="بورسعيد">بورسعيد</option>
					<option value="شمال سيناء">شمال سيناء</option>
					<option value="جنوب سيناء">جنوب سيناء</option>
					<option value="الغردقة">الغردقة</option>
					<option value="الشرقية">الشرقية</option>
					<option value="الغربية">الغربية</option>
					<option value="الدقهلية">الدقهلية</option>
					<option value="المنوفية">المنوفية</option>
					<option value="البحيرة">البحيرة</option>
					<option value="كفر الشيخ">كفر الشيخ</option>
					<option value="دمياط">دمياط</option>
					<option value="مرسى مطروح">مرسى مطروح</option>
					<option value="6 أكتوبر">6 أكتوبر</option>
					<option value="حلوان">حلوان</option>
					<option value="الفيوم">الفيوم</option>
					<option value="الوادي الجديد">الوادي الجديد</option>
					<option value="بني سويف">بني سويف</option>
					<option value="أسيوط">أسيوط</option>
					<option value="سوهاج">سوهاج</option>
					<option value="المنيا">المنيا</option>
					<option value="قنا">قنا</option>
					<option value="الأقصر">الأقصر</option>
					<option value="أسوان">أسوان</option>
				</select>
			</td>
			<td class="instructions">ستستخدم هذه المعلومة في الانتخابات، انتخابات المجلس الأعلى للتشريع.</td>
		</tr>
		<tr>
			<td><label for="description">اوصف نفسك:</label></td>
			<td><textarea id="description" name="description" rows="7" cols="30">{{description}}</textarea></td>
			<td class="instructions">اوصف نفسك في 140 حرفًا فقط. ستظهر هذه المعلومة أعلى صفحتك الشخصية وفي صفحة معلوماتك.</td>
		</tr>
		<tr>
			%rec_pub_key = site_info.get_by(name = u"recaptcha_public_key").value
			<td><label for="recaptcha_response_field">reCAPTCHA:</label></td>
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
			<td class="instructions">اكتب الكلمات الظاهرة في الصورة.</td>
		</tr>
		<tr>
			<td></td>
			<td><p><em>بضغطك على زر <strong>سجل</strong> بالاسفل، تكون قد وافقت على <a href="{{rq.script}}/rules">قوانين الموقع</a>.</em></p></td>
			<td></td>
		</tr>
		<tr>
			<td></td>
			<td><br /><input type="submit" id="submit" name="submit" class="submit" value="سجل" /></td>
		</tr>
	</table>
</form>
%end
%include footer args=args, rq=rq