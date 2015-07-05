<!-- edit Main Data -->
%from db import *
%from functions import *
%import random
%setup_all()

<a name="mdata"></a>
<h2>البيانات الأساسية</h2>

%if rq.q.has_key('editmdata'):
	%error = 0
	%email = 0
	%if rq.q.has_key('first_name'):
		%usr.first_name = escape(rq.q.getfirst('first_name','')).decode('utf8')
	%end
	%if rq.q.has_key('second_name'):
		%usr.second_name = escape(rq.q.getfirst('second_name','')).decode('utf8')
	%end
	%if rq.q.has_key('password'):
		%old_pass = return_hash_sha256(rq.q.getfirst('password','').decode('utf8'))
		%new_pass = rq.q.getfirst('new_password','').decode('utf8')
		%new_pass_again = rq.q.getfirst('new_password_again','').decode('utf8')
		%if old_pass == usr.password:
			%if len(new_pass) >= 6:
				%if new_pass == new_pass_again:
					%usr.password = return_hash_sha256(new_pass)
				%else:
					<div class="error"><p><strong>خطأ: </strong>كلمتا السر غير متطابقتان.</p></div>
					%error = 1
				%end
			%else:
				<div class="error"><p><strong>خطأ: </strong>كلمة السر الجديدة أقل من 6 أحرف.</p></div>
				%error = 1
			%end
		%else:
			<div class="error"><p><strong>خطأ: </strong>كلمة السر القديمة غير صحيحة.</p></div>
			%error = 1
		%end
	%end
	%if rq.q.has_key('email'):
		%new_email = escape(rq.q.getfirst('email','')).decode('utf8')
		%atpos = new_email.rfind("@")
		%dotpos = new_email.rfind(".")
		%if new_email != usr.email:
			%if (atpos < 1) or ((dotpos-atpos) < 2):
				<div class="error"><p><strong>خطأ: </strong>البريد الإلكتروني غير صحيح.</p></div>
				%error = 1
			%else:
				%usr.email = filter_en(new_email)
				%usr.is_active = 0
				%usr.active_hash = return_hash_sha256(str(random.randint(000000,999999))).decode('utf8')
				%email = 1
			%end
		%end
	%end
	%if rq.q.has_key('state'):
		%usr.state = escape(rq.q.getfirst('state','')).decode('utf8')
	%end
	%if rq.q.has_key('description'):
		%desc = escape(rq.q.getfirst('description','')).decode('utf8')
		%if len(desc) > 140:
			<div class="error"><p><strong>خطأ: </strong>لقد تعدى الوصف 140 حرفًا!</p></div>
			%error = 1
		%else:
			%usr.description = desc
		%end
	%end
	%if not error:
		%session.commit()
		%if email:
			%send_activate_msg(usr)
		%end
		<div class="note"><p>هنيـــــئًا! لــقد حُفِظت تعديلاتك بنجاح.</p></div>
	%end
%end

<form id="editMainData" name="editMainData" action="{{rq.script}}/user/{{usr.username}}/settings/mdata/#mdata" method="POST">
<input type="hidden" id="editmdata" name="editmdata" value="1" />
<table>
<tr>
	<td><label for="username">اسم المستخدم:</label></td>
	<td><span id="username">{{usr.username}}</label></td>
	<td class="instructions">لا يمكن تغييره!</td>
</tr>
<tr>
	<td><label for="first_name">الاسم الأول:</label></td>
	<td><input type="text" id="first_name" name="first_name" value="{{usr.first_name}}" />
	<td class="instructions">سيستخدم هذا الاسم للعرض في صفحتك الشخصية والتعليقات وخلافه.</td>
</tr>
<tr>
	<td><label for="second_name">الاسم الأخير:</label></td>
	<td><input type="text" id="second_name" name="second_name" value="{{usr.second_name}}" />
	<td class="instructions">سيستخدم هذا الاسم للعرض في صفحتك الشخصية والتعليقات وخلافه.</td>
</tr>
<tr>
	<td><label for="password">كلمة السر القديمة:</label></td>
	<td><input type="password" id="password" name="password" /></td>
	<td></td>
</tr>
<tr>
	<td><label for="new_password">كلمة السر الجديدة:</label></td>
	<td><input type="password" id="new_password" name="new_password" /></td>
	<td class="instructions">يجب أن تكون كلمة السر أكثر من 6 حروف، وأن تختلط الحروف بالأرقام.</td>
</tr>
<tr>
	<td><label for="new_password_again">إعادة كلمة السر:</label></td>
	<td><input type="password" id="new_password_again" name="new_password_again" /></td>
	<td class="instructions">تأكيدًا على حفظك لكلمة السر.</td>
</tr>
<tr>
	<td><label for="email">البريد الإلكتروني:</label></td>
	<td><input type="text" id="email" name="email" value="{{usr.email}}" /></td>
	<td class="instructions">عند تغييره، سيرسل رابط التفعيل إلى البريد الجديد، وسيعطل حسابك إلى أن تفعله من الرابط، لذا يجب أن يكون حقيقيًا.</td>
</tr>
<tr>
	<td><label for="state">المحافظة:</label></td>
	<td>
		<select id="state" name="state">
			<optgroup label="محافظتك الحالية">
			<option value="{{usr.state}}" selected="selected"><b>{{usr.state}}</b></option>
			</optgroup>
			<optgroup label="المحافظات الأخرى">
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
			</optgroup>
		</select>
	</td>
	<td class="instructions">ستستخدم هذه المعلومة في الانتخابات، انتخابات المجلس الأعلى للتشريع.</td>
</tr>
<tr>
	<td><label for="description">اوصف نفسك:</label></td>
	<td><textarea id="description" name="description" rows="7" cols="30">{{usr.description}}</textarea></td>
	<td class="instructions">اوصف نفسك في 140 حرفًا فقط. ستظهر هذه المعلومة أعلى صفحتك الشخصية وفي صفحة معلوماتك.</td>
</tr>
<tr>
	<td></td>
	<td><input type="submit" class="submit" id="submit" name="submit" value="حفظ" /></td>
	<td></td>
</tr>
</table>
</form>