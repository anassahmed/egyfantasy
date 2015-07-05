%from db import *
%from functions import *

%setup_all()
%if not args: 
	%raise redirectException(rq.script+'/users/')
%end

%if args:
	%usr = get_user_by_name(args[0].decode('utf8'))
	%if usr == None: 
		%raise fileNotFoundException()
	%end
	%if usr.is_banned:
		%raise forbiddenException()
	%end
%end

%full_name = get_full_name(usr)
%title = full_name
%usr_url = get_relative_user_url(rq, usr)

%if args:
	%if len(args) == 1:
		%pass
	%elif args[1] == 'info':
		%title += " > المعلومات"
	%elif args[1] == 'settings':
		%title += " > إدارة الحساب"
	%elif args[1] == 'notices':
		%title += " > الإشعارات"
	%elif args[1] == 'topics':
		%title += " > المواضيع"
		%if len(args) == 3:
			%t = get_topic(id = int(args[2]))
			%if t == None:
				%raise fileNotFoundException()
			%else:
				%title += " > "+t.title.encode('utf8')
			%end
		%end
	%end
%end

%include header args=args, rq=rq, title=title, description=usr.description

<div id="userInfo">
	<img id="avatar" src="{{get_avatar(usr, 200)}}" alt="الصورة الشخصية" title="{{full_name}}" />
	<h1>{{full_name}}</h1>
	<span id="username" dir="ltr"><a href="{{usr_url}}/">@{{usr.username}}</a></span>
	<p id="userDescription">{{usr.description}}</p>
	<div id="btnsBox">
	<a href="{{usr_url}}/info/#info" style="text-decoration: none;" id="moreInfo"><button class="submit">اعرف المزيد</button></a>
	</div>
</div>

<div id="userMenu">
	<h3>الرئيسية</h3>
	<ul class="vertical-menu">
		<li><a href="{{usr_url}}/#main">الرئيسية</a></li>
		<li><a href="{{usr_url}}/info/#info">المعلومات</a></li>
		<li><a href="{{usr_url}}/notices/#notice">الإشعارات</a></li>
		<li><a href="{{usr_url}}/topics/#topic">المواضيع</a></li>
	</ul>
	%if whoLoggedin(rq) != None and whoLoggedin(rq) != usr:
	<h3>تواصل</h3>
	<ul class="vertical-menu">
		<li><a href="{{usr_url}}/#notice">أرسل إشعارًا</a></li>
		<li><a href="{{usr_url}}/send/#msg">أرسل رسالة</a></li>
		<li><a href="{{usr_url}}/report/#report">أبلغ عن شخص</a></li>
	</ul>
	%end
	%socials = get_user_meta_stwith(usr, u'social')
	%if len(socials) > 0:
	<h3>إجتماعيات</h3>
	<ul class="horizontal-menu">
		%for i in socials:
		<li><a href="{{i.value}}" target="_blank"><img src="{{rq.script}}/images/{{i.name[7:]}}.png" alt="{{i.name[7:]}}" title="{{i.name[7:]}}" /></a></li>
		%end
	</ul>
	%end
	%if whoLoggedin(rq) == usr:
	<h3>إدارة الحساب</h3>
	<ul class="vertical-menu">
		<li><a href="{{rq.script}}/settings/">رئيسية الإدارة</a></li>
		<h4>إدارة البيانات</h4>
		<li><a href="{{usr_url}}/settings/exdata/#exdata">البيانات الإضافية</a></li>
		<li><a href="{{usr_url}}/settings/socials/#socials">الشبكات الإجتماعية</a></li>
		<li><a href="{{usr_url}}/settings/avatar/#gravatar">الصورة الشخصية</a></li>
		<li><a href="{{usr_url}}/settings/mdata/#mdata">البيانات الأساسية</a></li>
	</ul>
	%end
</div>

<div id="userContent">
	<!-- includes all sub-pages -->
	%if len(args) == 1:
		%include user_main args=args, rq=rq, usr=usr
	%elif args[1] == 'info':
		%include user_info args=args, rq=rq, usr=usr
	%elif args[1] == 'notices':
		%include user_notices args=args, rq=rq, usr=usr
	%elif args[1] == 'topics':
		%include user_topics args=args, rq=rq, usr=usr
	%elif args[1] == 'report':
		%form = True
		%r = reports.query.filter_by(user = usr).filter_by(who_reported = whoLoggedin(rq).id).first()
		%if whoLoggedin(rq) == usr or whoLoggedin(rq) == None or r != None:
			%raise forbiddenException()
		%else:
			%if rq.q.has_key('reason'):
				%if len(usr.reports) == 10:
					%usr.is_banned = 1
					%usr.ban_reason = escape(rq.q.getfirst('reason','').decode('utf8'))
				%else:
					%r = reports(user = usr, who_reported = whoLoggedin(rq).id, report_text = escape(rq.q.getfirst('reason').decode('utf8')))
				%end
				%session.commit()
				<a name="report"></a>
				<div class="note"><p>لقد أُرسِلَ إبلاغك، وسيراجع بواسطة الإدارة.</p></div>
				%form = False
			%end
			%if form:
				<a name="report"></a>
				<h2>أبلغ عن شخص</h2>
				<form id="reportUser" name="reportUser" action="{{usr_url}}/report/#report" method="POST">
					<p>
					<label for="username">اسم المستخدم المبلغ عنه:</label>
					<span id="username">{{usr.username}}</span>
					</p>
					<p>
					<label for="reason">سبب الإبلاغ:</label>
					<textarea id="reason" name="reason" style="width:98%;"></textarea>
					</p>
					<div class="clear"></div>
					<div style="float:left;">
					<input type="submit" id="submit" name="submit" value="أبلغ" />
					<a href="{{usr_url}}/#main"><input type="button" value="ألغِ" /></a>
					</div>
				</form>
			%end
		%end
	%elif args[1] == 'settings':
		%include user_settings args=args, rq=rq, usr=usr
	%end
</div>

%include footer args=args, rq=rq