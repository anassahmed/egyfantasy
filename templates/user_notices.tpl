<!-- user notices -->
%from db import *
%from functions import *
%setup_all()

%from urllib2 import *

<a name="notice"></a>
<span class="hidden" id="shortUrl" value=""></span>

%if len(args) == 2:
<h2>الإشعارات</h2>
%end

%if rq.q.has_key('deletenotice') and rq.q.has_key('notice_id'):
	%n = get_notice(rq.q.getfirst('notice_id'))
	%if whoLoggedin(rq) == n.user:
		%n.delete()
		%session.commit()
		<div class="note"><p>حُذِف الإشعار بنجاح!</p></div>
	%else:
		<div class="error"><p><strong>خطأ: </strong>لا يمكنك حذف هذا الإشعار!</p></div>
	%end
%end

%usr_url = get_relative_user_url(rq, usr)

%if whoLoggedin(rq) != None:
	%notice_text = ""
	%if rq.q.has_key('addnotice') and rq.q.has_key('notice_text'):
		%final_notice = filter_notice(rq.q.getfirst('notice_text').decode('utf8'), rq)
		%if final_notice != -1 and final_notice != 0:
			%new_notice = notice(text = final_notice['t'], time = now(), user = whoLoggedin(rq))
			%no = notifications(type = u'mention', object = u'notice', notice = new_notice, time = now())
			%sub = subscriptions(notice = new_notice)
			%me = mentions(who_mentioned = whoLoggedin(rq).id, notice = new_notice)
			%if len(final_notice['users']) > 0:
				%for i in final_notice['users']:
					%me.user.append(i)
					%sub.users.append(i)
					%no.user.append(i)
				%end
			%end
			%sub.users.append(whoLoggedin(rq))
			%if len(final_notice['tags']) > 0:
				%for i in final_notice['tags']:
					%tag = tags.get_by(name = i)
					%if tag == None:
						%tag = tags(name = i)
					%end
					%tag.notices.append(new_notice)
				%end
			%end
			%session.commit()
			<div class="note"><p>أُضيف إشعارك بنجاح!</p></div>
		%else:
			%if final_notice == 0:
			<div class="error"><p><strong>خطأ: </strong>عدد أحرف إشعارك أكثر من 140 حرفًا!</p></div>
			%elif final_notice == -1:
			<div class="error"><p><strong>خطأ: </strong>أحد المستخدمين الذين ذكرتهم في إشعارك غير موجود.</p></div>
			%end
			%notice_text = escape(rq.q.getfirst('notice_text'))
		%end
	%end
	<h3>أرسل إشعارًا</h3>
	<p>اكتب ما تفكر فيه ...</p>
	<form id="addNotice" name="addNotice" action="{{usr_url}}/notices/#notice" method="POST">
	<input type="hidden" id="addnotice" name="addnotice" value="1" />
	%if whoLoggedin(rq) != usr:
		%d = u'@'+usr.username+u' '
	%else:
		%d = ""
	%end
	<textarea id="notice_text" name="notice_text">{{d}}{{notice_text}}</textarea>
	<input type="submit" id="submit" name="submit" value="أرسل" />
	</form>
%end		

<br style="clear:both;" />
%if len(args) <= 2:
	<a name="latest-notices"></a>
	<h3>آخر الإشعارات</h3>
	%if len(args) < 2:
		%l_notices = get_last_user_notices(usr)
	%else:
		%if rq.q.has_key('p'):
			%l_notices = get_last_user_notices(usr, 10, int(rq.q.getfirst('p')))
			%if len(l_notices) == 0:
				<div class="error"><p><strong>خطأ: </strong>لا توجد صفحة بهذا الرقم.</p></div>
			%end
		%else:
			%l_notices = get_last_user_notices(usr, 10)
		%end
	%end
	%n_count = get_user_notices_count(usr)
	%if n_count == 0:
		<div class="note"><p>هذا المستخدم لم يُرسل بعدُ أية إشعارات.</p></div>
	%else:
		%for i in l_notices:
			%user_url = get_relative_user_url(rq, i.user)
			<div class="meta" style="float: left; clear: none; display: inline; margin: 0; padding: 0;">
				<span class="share"><label>شارك:</label>&nbsp;
					%fb_title = 'الخيال المصري | %s > %s' %(get_full_name(i.user), 'الإشعارات')
					%tw_text = get_first_part(u'RT|%s %s' %(i.user.username, i.text), 118).encode('utf8')
					%link = get_site_url()+user_url.decode('utf8')+u'/notices/'+str(i.id).decode('utf8')
					<a href="javascript: void(0)" onClick="return fbs_click('{{link}}','{{fb_title}}')" ><img src="{{rq.script}}/images/facebook_share.png" alt="facebook" /></a>
					<a href="javascript: void(0)" onClick="short_url('{{link}}'); setTimeout(function() {tws_click(getShortUrl(),'{{tw_text}}')}, 2000)"><img src="{{rq.script}}/images/twitter_share.png" alt="twitter" /></a>
				</span>
			</div>
			<div class="noticeItem">
				<div class="avatar">
					<a href="{{user_url}}/"><img src="{{get_avatar(i.user, 70)}}" alt="{{i.user.username}}" /></a>
				</div>
				<div class="text">
					<div class="username"><b><a href="{{user_url}}/">{{get_full_name(i.user)}}</a></b></div>
					<p class="noticeText">{{!i.text}}</p>
					<div class="meta">
						<span class="time"><a href="{{user_url}}/notices/{{i.id}}#viewNotice">{{arstrftime(i.time)}}</a></span>
						<span class="comments"><a href="{{user_url}}/notices/{{i.id}}#comments">{{len(i.comments)}} تعليقـ/ـات</a></span>
						%if whoLoggedin(rq) != None:
							%if whoLoggedin(rq) == i.user:
								<span class="delete">
								<a href="{{user_url}}/notices/{{i.id}}/delete/#delete">احذف</a>
								</span>
							%else:
								<span class="report">
								<a href="{{user_url}}/notices/{{i.id}}/report/#report">أبلغ</a>
								</span>
							%end
						%end
					</div>
				</div>
			</div>
		%end
		%if len(args) == 2:
			%if n_count > 10:
				<div id="pages">
				%pn = n_count / 10
				%if n_count % 10 != 0:
					%pn += 1
				%end 
				%pn += 1
				%for i in range(1, pn):
					<a class="round" href="{{usr_url}}/notices/?p={{i}}#notice">{{i}}</a>
				%end
				</div>
			%end
		%end
	%end
%else:
	%n = get_notice(id = args[2])
	%user_url = get_relative_user_url(rq, n.user)
	%if n.user != usr:
		%raise fileNotFoundException()
	%end
	%if len(args) > 3 and args[3] == 'delete':
		%if whoLoggedin(rq) == n.user:
			<a name="delete"></a>
			<div class="note" id="delete">
				<p>هل تريد حقًا حذف هذا الإشعار؟</p>
			<form id="deleteNotice" name="deleteNotice" action="{{user_url}}/notices/#notice" method="POST">
				<input type="hidden" id="deletenotice" name="deletenotice" value="1" />
				<input type="hidden" id="notice_id" name="notice_id" value="{{n.id}}" />
				<input type="submit" id="submit" name="submit" value="احذف" />
				<a href="{{user_url}}/notices/{{n.id}}#viewNotice">
				<input type="button" id="cancel" name="cancel" value="ألغِ" /></a>
			</form>
			</div>
		%else:
			<div class="error"><p><strong>خطأ: </strong>لا تملك الصلاحيات الكافية لحذف هذا الإشعار.</p></div>
		%end
	%elif len(args) > 3 and args[3] == 'report':
		%form = True
		%r = reports.query.filter_by(notice = n).filter_by(who_reported = whoLoggedin(rq).id).first()
		%if whoLoggedin(rq) == usr or whoLoggedin(rq) == None or r != None:
			%raise forbiddenException()
		%else:
			%if rq.q.has_key('reason'):
				%if len(n.reports) == 10:
					%for i in n.comments:
						%i.delete()
					%end
					%n.delete()
					%session.commit()
				%else:
					%r = reports(notice = n, who_reported = whoLoggedin(rq).id, report_text = escape(rq.q.getfirst('reason').decode('utf8')))
				%end
				%session.commit()
				<a name="report"></a>
				<div class="note"><p>لقد أُرسِلَ إبلاغك، وسيراجع بواسطة الإدارة.</p></div>
				%form = False
			%end
			%if form:
				<a name="report"></a>
				<h3>أبلغ عن إشعار</h3>
				<form id="reportNotice" name="reportNotice" action="{{user_url}}/notices/{{n.id}}/report/#report" method="POST">
					<p>
					<label for="reason">سبب الإبلاغ:</label>
					<textarea id="reason" name="reason" style="width:98%;"></textarea>
					</p>
					<div class="clear"></div>
					<div style="float:left;">
					<input type="submit" id="submit" name="submit" value="أبلغ" />
					<a href="{{user_url}}/notices/{{n.id}}#notice"><input type="button" value="ألغِ" /></a>
					</div>
					<div class="clear"></div>
				</form>
			%end
		%end
	%end
	<a name="viewNotice"></a> 
	<div class="meta" style="float: left; margin-top: 0px;">
		<span class="share"><label>شارك:</label>&nbsp;
			%fb_title = 'اليخيال المصري | %s > %s' %(get_full_name(n.user), 'الإشعارات')
			%tw_text = get_first_part(u'RT|%s %s' %(n.user.username, n.text), 118).encode('utf8')
			%try:
				%link = shorten_url(get_site_url()+user_url.decode('utf8')+u'/notices/'+str(n.id).decode('utf8'))
			%except URLError:
				%link = get_site_url()+user_url.decode('utf8')+u'/notices/'+str(n.id).decode('utf8')
			<a href="javascript: void(0)" onClick="return fbs_click('{{link}}','{{fb_title}}')" ><img src="{{rq.script}}/images/facebook_share.png" alt="facebook" /></a>
			<a href="javascript: void(0)" onClick="short_url('{{link}}'); setTimeout(function() {tws_click(getShortUrl(),'{{tw_text}}')}, 2000)"><img src="{{rq.script}}/images/twitter_share.png" alt="twitter" /></a>
		</span>
	</div>
	<h4>عرض الإشعار</h4>
	<div class="viewNotice">
		<div class="avatar">
			<a href="{{user_url}}/"><img src="{{get_avatar(n.user, 100)}}" alt="{{n.user.username}}" /></a>
		</div>
		<div class="text">
			<div class="username"><b><a href="{{user_url}}/">{{get_full_name(n.user)}}</a></b></div>
			<p class="noticeText">{{!n.text}}</p>
			<div class="meta">
				<span class="time"><a href="{{user_url}}/notices/{{n.id}}#viewNotice">{{arstrftime(n.time)}}</a></span>
				%if whoLoggedin(rq) != None:
					%if whoLoggedin(rq) == n.user:
						<span class="delete">
						<a href="{{user_url}}/notices/{{n.id}}/delete/#delete">احذف</a>
						</span>
					%else:
						<span class="report">
						<a href="{{user_url}}/notices/{{n.id}}/report/#report">أبلغ</a>
						</span>
					%end
				%end
			</div>
		</div>
	</div>
	%include comments args=args, rq=rq, usr=usr, obj='notice', obj_id=n.id
%end