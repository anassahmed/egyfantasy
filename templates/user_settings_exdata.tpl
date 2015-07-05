<!-- edit extra data -->
%from db import *
%from functions import *
%setup_all()

<style type="text/css">
	form input[type=text] {
		width: 200px;
	}
</style>

<a name="exdata"></a>
<h2>البيانات الإضافية</h2>

%if rq.q.has_key('editextra'):
	%error = 0
	%if rq.q.has_key('gender'):
		%gender_meta = get_user_meta(usr, u'extra_gender')
		%if gender_meta == None:
			%gender_meta = user_meta(user= usr, name = u"extra_gender", value = escape(rq.q.getfirst('gender','')).decode('utf8'))
		%else:
			%gender_meta.value = escape(rq.q.getfirst('gender','')).decode('utf8')
		%end
	%end
	%if rq.q.has_key('religion'):
		%religion_meta = get_user_meta(usr, u'extra_religion')
		%if religion_meta == None:
			%religion_meta = user_meta(user = usr, name = u"extra_religion", value = escape(rq.q.getfirst('religion','')).decode('utf8'))
		%else:
			%religion_meta.value = escape(rq.q.getfirst('religion','')).decode('utf8')
		%end
	%end
	%if rq.q.has_key('website'):
		%if rq.q.getfirst('website','').startswith('http://') and rq.q.getfirst('website','') != "http://":
			%website_meta = get_user_meta(usr, u'extra_website')
			%if website_meta == None:
				%website_meta = user_meta(user = usr, name = u"extra_website", value = filter_en(escape(rq.q.getfirst('website','')).decode('utf8')))
			%else:
				%website_meta.value = filter_en(escape(rq.q.getfirst('website','')).decode('utf8'))
			%end
		%else:
			<div class="error"><p><strong>خطأ: </strong>الموقع الإلكتروني غير صحيح. لم يُحفظ!</p></div>
			%error = 1
		%end
	%end
	%if rq.q.has_key('interrests'):
		%interrests_meta = get_user_meta(usr, u'extra_interrests')
		%if interrests_meta == None:
			%interrests_meta = user_meta(user = usr, name = u"extra_interrests", value = escape(rq.q.getfirst('interrests','')).decode('utf8'))
		%else:
			%interrests_meta.value = escape(rq.q.getfirst('interrests','')).decode('utf8')
		%end
	%end
	%if not error:
		%session.commit()
		<div class="note"><p>هنيـــــئًا! لــقد حُفِظت تعديلاتك بنجاح.</p></div>
	%end
%end

<form id="editExtraData" name="editExtraData" action="{{rq.script}}/user/{{usr.username}}/settings/exdata/#exdata" method="POST">
<input type="hidden" id="editextra" name="editextra" value="1" />
<table>
	<tr>
	<td><label for="gender">النوع:</label></td>
	<td>
	%gender = get_user_meta(usr, u'extra_gender')
	%male = ""
	%female = ""
	%if gender != None:
		%if gender.value == u"ذكر":
			%male = "checked='checked'"
		%elif gender.value == u"أنثى":
			%female = "checked='checked'"
		%end
	%end
	<input type="radio" id="gender_male" name="gender" value="ذكر" {{male}} />
	<label for="gender_male">ذكر</label>
	<input type="radio" id="gender_female" name="gender" value="أنثى" {{female}} />
	<label for="gender_female">أنثى</label>
	</td>
</tr>
<tr>
	<td><label for="religion">الديانة:</label></td>
	<td>
	%religion = get_user_meta(usr, u'religion')
	<select id="religion" name="religion">
		%if religion != None:
		<optgroup label="الديانة الحالية">
			<option value="{{religion.value}}">{{religion.value}}</option>
		</optgroup>
		<optgroup label="الديانات الأخرى">
		%end
			<option value="مسلم">مسلم</option>
			<option value="مسيحي">مسيحي</option>
			<option value="يهودي">يهودي</option>
			<option value="أخرى">أخرى</option>
		%if religion != None:
		</optgroup>
		%end
	</select>
	</td>
</tr>
<tr>
	%website = get_user_meta(usr, u'extra_website')
	%w = ""
	%if website != None:
		%w = website.value
	%end
	<td><label for="website">الموقع الإلكتروني:</label></td>
	<td><input type="text" class="ltr" id="website" name="website" value="{{w}}" /></td>
</tr>
<tr>
	%interrests = get_user_meta(usr, u'extra_interrests')
	%ins = ""
	%if interrests != None:
		%ins = interrests.value
	%end
	<td><label for="interrests">الاهتمامات:</label></td>
	<td><input type="text" id="interrests" name="interrests" value="{{ins}}" /></td>
</tr>
<tr>
	<td></td>
	<td><br /><br /><input type="submit" class="submit" id="submit" name="submit" value="حفظ" />
</tr>
</table>
</form>