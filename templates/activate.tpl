%include header args=args, rq=rq, title="التفعيل"
%from functions import *
%from db import *
%setup_all()

%if not args:
	%if not rq.q.has_key('facebook'):
		%raise forbiddenException()
	%end
	%if rq.q.has_key('user_id'):
		%usr = users.get_by(id = int(rq.q.getfirst('user_id')))
		%txt = "http://www.facebook.com/"
		%if rq.q.getfirst("facebook","").startswith(txt) and rq.q.getfirst("facebook","") != txt:
			%facebook_meta = user_meta(name = u"social_facebook", value = escape(rq.q.getfirst("facebook","")).decode('utf8'), user = usr)
		%end
		%txt = "http://www.twitter.com/"
		%if rq.q.getfirst("twitter","").startswith(txt) and rq.q.getfirst("twitter","") != txt:
			%twitter_meta = user_meta(name = u"social_twitter", value = escape(rq.q.getfirst("twitter","")).decode('utf8'), user = usr)
		%end
		%txt = "http://www.identi.ca/"
		%if rq.q.getfirst("identica","").startswith(txt) and rq.q.getfirst("identica","") != txt:
			%identica_meta = user_meta(name = u"social_identica", value = escape(rq.q.getfirst("identica","")).decode('utf8'), user = usr)
		%end
		%if rq.q.has_key('gender'):
			%gender_meta = user_meta(name = u"extra_gender", value = escape(rq.q.getfirst("gender","")).decode('utf8'), user = usr)
		%end
		%if rq.q.has_key('religion'):
			%religion_meta = user_meta(name = u"extra_religion", value = escape(rq.q.getfirst("religion","")).decode('utf8'), user = usr)
		%end
		%if rq.q.has_key('website') and rq.q.getfirst('website','').startswith('http://') and rq.q.getfirst('website','') != 'http://':
			%website_meta = user_meta(name = u"extra_website", value = escape(rq.q.getfirst("website","")).decode('utf8'), user = usr)
		%end
		%if rq.q.has_key("interrests"):
			%interrests_meta = user_meta(name = u"extra_interrests", value = escape(rq.q.getfirst("interrests","")).decode('utf8'), user = usr)
		%end
		%session.commit()
		<div class="note" id="success"><p>تهانينا! لقد حُفظت البيانات الإضافية بنجاح. سيتم نقلك خلال ثوان إلى الصفحة الرئيسية، إذا كان متصفحك لا يدعم الانتقال التلقائي <a href="{{rq.script}}/">اضغط هنا</a>.</p></div>
		<head>
			<meta http-equiv="refresh" content="5;{{rq.script}}/" />
		</head>
	%end
%end
%if args:
	%usr = users.get_by(active_hash = escape(args[0]))
	%if usr == None:
		<div class="error"><p><strong>خطأ: </strong> رقم تفعيل غير صحيح.</p></div>
	%end
	%if usr != None:
		%if usr.is_active:
			<div class="error"><p><strong>خطأ: </strong>لقد فُعِّل هذا الحساب من قبل.</p></div>
		%end
		%m = user_meta.query.filter_by(user = usr).all()
		%if not usr.is_active and m != []:
			<div class="note"><p>هنيئًا! لقد فُعِّلت عضويتك بنجاح. يمكنك الآن المشاركة معنا في الموقع.</p></div>
		%end
		%if not usr.is_active and m == []:
			%usr.is_active = 1
			%session.commit()
			<div class="note"><p>هنيئًا! لقد فُعِّلت عضويتك بنجاح. يمكنك الآن المشاركة معنا في الموقع.</p></div>
			<h1>ما بعد التفعيل</h1>
			<div class="note"><p>هنيئًا! لقد فُعِّلت عضويتك بنجاح. يمكنك الآن المشاركة معنا في الموقع.</p></div>
			<p>هذه بضع خطوات بسيطة لاستكمال بعض البيانات الإضافية. وهي في النهاية بيانات اختيارية يمكنك تخطيها.</p>

			<h2>الصورة الشخصية</h2>
			<p>يعتمد موقعنا على تقنية Gravatar للصور الشخصية، إذا كنت مشتركًا في الخدمة من قبل فستظهر صورتك بالأسفل، وإلا ستظهر صورة ظل مجهول.</p>
			<p>تعتمد خدمة Gravatar على البريد الإلكتروني الذي أدخلته سابقًا في عملية التسجيل، فإذا لم تكن مشتركًا في Gravatar يمكنك الضغط على زر "إضافة/تغيير الصورة الشخصية" وستظهر لك نافذة للاشتراك أو إذا كنت مشتركًا ستظهر نافذة لتغيير الصورة.</p>
			<br />
			<img src="{{get_avatar(usr, 200)}}" alt="الصورة الشخصية" />
			<br /><br />
			<a href="http://ar.gravatar.com/emails" target="_blank" style="text-decoration: none;"><button id="registerGravatar">إضافة/تغيير الصورة الشخصية</button></a>

			<h2>بيانات الشبكات الإجتماعية</h2>
			<style type="text/css">
				form#extraInfo input[type=text] {
					width: 200px;
				}
			</style>
			<form id="extraInfo" name="extraInfo" action="{{rq.script}}/activate/" method="POST">
				<input type="hidden" id="user_id" name="user_id" value="{{usr.id}}" />
			<table>
			<tr>
				<td><label for="facebook">حساب فيس بوك:</label></td>
				<td class="ltr">
				<span>http://www.facebook.com/</span><input type="text" id="facebook" name="facebook" />
				</td>
			</tr>
			<tr>
				<td><label for="twitter">حساب تويتر:</label></td>
				<td class="ltr">
				<span>http://www.twitter.com/</span><input type="text" id="twitter" name="twitter" />
				</td>
			</tr>
			<tr>
				<td><label for="identica">حساب أيدينتيكا:</label></td>
				<td class="ltr">
				<span>http://www.identi.ca/</span><input type="text" id="identica" name="identica" />
				</td>
			</tr>
			</table>
			
			<h2>البيانات الإضافية</h2>
			<table>
			<tr>
				<td><label for="gender">النوع:</label></td>
				<td><input type="radio" id="gender_male" name="gender" value="ذكر" />
				<label for="gender_male">ذكر</label>
				<input type="radio" id="gender_female" name="gender" value="أنثى" />
				<label for="gender_female">أنثى</label></td>
			</tr>
			<tr>
				<td><label for="religion">الديانة:</label></td>
				<td><select id="religion" name="religion">
					<option value="مسلم">مسلم</option>
					<option value="مسيحي">مسيحي</option>
					<option value="يهودي">يهودي</option>
					<option value="أخرى">أخرى</option>
				</select></td>
			</tr>
			<tr>
				<td><label for="website">الموقع الإلكتروني:</label></td>
				<td><input type="text" class="ltr" id="website" name="website" value="http://" /></td>
			</tr>
			<tr>
				<td><label for="interrests">الاهتمامات:</label></td>
				<td><input type="text" id="interrests" name="interrests" /></td>
			</tr>
			<tr>
				<td></td>
				<td><br /><br /><input type="submit" class="submit" id="submit" name="submit" value="حفظ" />
				<a href="{{rq.script}}/" style="text-decoration: none;"><input type="button" class="submit" id="ignore" name="ignore" value="تخطي" /></a></td>
			</tr>
			</table>
			</form>
		%end
	%end
%end

%include footer args=args, rq=rq