<!-- user information -->
%from db import *
%from functions import *
%setup_all()

<a name="info"></a>
<h2>المعلومات</h2>
<table>
<tr><td><h3>البيانات الأساسية</h3></td></tr>
<tr><td>
	<table>
	<tr>
		<td style="width: 125px;"><label for="username">اسم المستخدم:</label></td>
		<td><span id="username">{{usr.username}}</span></td>
	</tr>
	<tr>
		<td><label for="full_name">الاسم الكامل:</label></td>
		<td><span id="full_name">{{usr.first_name}} {{usr.second_name}}</td>
	</tr>
	<tr>
		<td><label for="state">المحافظة:</label></td>
		<td><span id="state">{{usr.state}}</td>
	</tr>
	<tr>
		<td><label for="description">الوصف:</label></td>
		<td><p>{{usr.description}}</p></td>
	</tr>
	</table>
</td></tr>
%extra_data = get_user_meta_stwith(usr, u'extra_')
%if len(extra_data) > 0:
<tr><td><h3>البيانات الإضافية</h3></td></tr>
<tr><td>
	<table>
	%for i in extra_data:
		<tr>
		%name_en = i.name[6:]
		%if name_en == u"gender":
			%name = u"النوع"
		%elif name_en == u"religion":
			%name = u"الديانة"
		%elif name_en == u"website":
			%name = u"الموقع الإلكتروني"
		%elif name_en == u"interrests":
			%name = u"الاهتمامات"
		%end
			<td style="width: 125px;"><label for="{{name_en}}">{{name}}:</label></td>
		%if name_en == u"website":
			<td><a href="{{i.value}}" id="{{name_en}}" target="_blank">{{i.value}}</a></td>
		%else:
			<td><span id="{{name_en}}">{{i.value}}</span></td>
		%end
		</tr>
	%end
	</table>
	</td></tr>
%end
%socials = get_user_meta_stwith(usr, u'social_')
%if len(socials) > 0:
<tr><td><h3>الشبكات الإجتماعية</h3></td></tr>
<tr><td>
	<table>
	%for i in socials:
		<tr>
		<td style="width: 125px;"><label for="{{i.name[7:]}}">{{i.name[7:]}}:</label></td>
		<td><a href="{{i.value}}" target="_blank">{{i.value}}</a></td>
		</tr>
	%end
	</table>
</td></tr>
%end
</table>