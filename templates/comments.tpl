<!-- comments -->

%from db import *
%from functions import *

%setup_all()

%if obj == 'notice':
	%o = notice.get_by(id = obj_id)
	%obj_url = '/notices'
%elif obj == 'topic':
	%o = topic.get_by(id = obj_id)
	%obj_url = '/topics'
%elif obj == 'mail':
	%o = mail.get_by(id = obj_id)
	%obj_url = '/mail'
%else:
	%raise fileNotFoundException()
%end

%user_url = get_relative_user_url(rq, o.user)
%o_url = user_url + obj_url
<div id="comments">
<a name="comments"></a>
<h3>التعليقات</h3>
<p>عدد التعليقات: {{len(o.comments)}}</p>

%if whoLoggedin(rq) != None:
	%if rq.q.has_key('comment_text'):
		%c = comment(user = whoLoggedin(rq), text = filter_text_html(rq.q.getfirst('comment_text','').decode('utf8')), time = now())
		%if obj == 'notice':
			%c.notice = o
			%p = notifications.query.filter_by(type = u"ParentComment", object = obj.decode('utf8'), parent = 0, notice = o).first()
			%if p == None:
				%p = notifications(type = u"ParentComment", object = obj.decode('utf8'), parent = 0, notice = o)
			%end
		%elif obj == 'topic':
			%c.topic = o
			%p = notifications.query.filter_by(type = "ParentComment", object = obj.decode('utf8'), parent = 0, topic = o).first()
			%if p == None:
				%p = notifications(type = u"ParentComment", object = obj.decode('utf8'), parent = 0, topic = o)
			%end
		%elif obj == 'mail':
			%c.mail = o
		%end
		%no = notifications(type = u'comment', parent = p.id, object = obj.decode('utf8'), time = now())
		%if obj == 'notice':
			%no.notice = o
		%elif obj == 'topic':
			%no.topic = o
		%end
		%for i in o.subscriptions:
			%for u in i.users:
				%if u != whoLoggedin(rq):
					%no.user.append(u)
				%end
			%end
			%try:
				%ut = i.users.index(whoLoggedin(rq))
			%except ValueError:
				%i.users.append(whoLoggedin(rq))
			%end
		%end
		%session.commit()
		<div class="note"><p>أُضيف تعليقك بنجاح!</p></div>
	%elif rq.q.has_key("delete_comment"):
		<a name="delete"></a>
		<div class="note"><p>هل تريد حقًا حذف هذا التعليق؟</p>
		<form id="deleteComment" name="deleteComment" action="{{o_url}}/{{o.id}}#comments" method="POST">
			<input type="hidden" id="delete_comment_id" name="delete_comment_id" value="{{rq.q.getfirst('delete_comment','')}}" />
			<input type="submit" id="submit" name="submit" value="احذف" />
			<a href="{{o_url}}/{{o.id}}#comment-{{rq.q.getfirst('delete_comment')}}"><input type="button" value="ألغِ" /></a>
		</form>
		</div>
	%elif rq.q.has_key('report_comment'):
		<a name="report"></a>
		%c = comment.get_by(id = int(rq.q.getfirst('report_comment','')))
		%r = reports.query.filter_by(comment = c).filter_by(who_reported = whoLoggedin(rq).id).first()
		%if whoLoggedin(rq) == None or r != None:
			<div class="error"><p><strong>خطأ: </strong>لا يمكنك الإبلاغ عن هذا التعليق!</p></div>
		%else:
			<div class="note"><p>ما سبب إبلاغك عن هذا التعليق؟</p>
			<form id="reportComment" name="reportComment" action="{{o_url}}/{{o.id}}#report" method="POST">
				<input type="hidden" id="report_comment_id" name="report_comment_id" value="{{rq.q.getfirst('report_comment','')}}" />
				<textarea id="report_comment_reason" name="report_comment_reason" style="width: 98%;"></textarea>
				<input type="submit" id="submit" name="submit" value="أبلغ" />
				<a href="{{o_url}}/{{o.id}}#comment-{{rq.q.getfirst('report_comment')}}"><input type="button" value="ألغِ" /></a>
			</form>
			</div>
		%end
	%elif rq.q.has_key('delete_comment_id'):
		%c = comment.get_by(id = int(rq.q.getfirst('delete_comment_id')))
		%c.delete()
		%session.commit()
		<div class="note"><p>حُذف التعليق بنجاح!</p></div>
	%elif rq.q.has_key('report_comment_id'):
		%c = comment.get_by(id = int(rq.q.getfirst('report_comment_id','')))
		%r = reports.query.filter_by(comment = c).filter_by(who_reported = whoLoggedin(rq).id).first()
		%if whoLoggedin(rq) == None or r != None:
			<div class="error"><p><strong>خطأ: </strong>لا يمكنك الإبلاغ عن هذا التعليق!</p></div>
		%else:
			%if rq.q.has_key('report_comment_reason'):
				%if len(c.reports) == 10:
					%for i in n.comments:
						%i.delete()
					%end
					%c.delete()
					%session.commit()
				%else:
					%r = reports(comment = c, who_reported = whoLoggedin(rq).id, report_text = escape(rq.q.getfirst('report_comment_reason').decode('utf8')))
				%end
				%session.commit()
				<a name="report"></a>
				<div class="note"><p>لقد أُرسِلَ إبلاغك، وسيراجع بواسطة الإدارة.</p></div>
			%end
		%end
	%end
	<h4>أضف تعليقًا</h4>
	<form id="addComment" name="addComment" action="{{o_url}}/{{o.id}}#comments" method="POST">
		<textarea id="comment_text" name="comment_text"></textarea>
		<input type="submit" id="submit" name="submit" value="عَلِّق" />
	</form>
%end

%if len(o.comments) == 0:
	<div class="clear"></div>
	<div class="note"><p>لا توجد تعليقات، كن أول من يعلق!</p></div>
%else:
	%for i in o.comments:
		%user_c_url = get_relative_user_url(rq, i.user)
		<a name="comment-{{i.id}}"></a>
		<div class="viewComment">
			<div class="avatar">
				<a href="{{user_c_url}}/"><img src="{{get_avatar(i.user, 70)}}" alt="{{i.user.username}}" /></a>
			</div>
			<div class="text">
				<div class="username"><b><a href="{{user_c_url}}/">{{get_full_name(i.user)}}</a></b></div>
				<p class="commentText">{{!i.text}}</p>
				<div class="meta">
					<span class="time"><a href="{{o_url}}/{{o.id}}#comment-{{i.id}}">{{arstrftime(i.time)}}</a></span>
					%if whoLoggedin(rq) != None:
						%if whoLoggedin(rq) == i.user:
							<span class="delete">
							<a href="{{o_url}}/{{o.id}}?delete_comment={{i.id}}#delete">احذف</a>
							</span>
						%else:
							<span class="report">
							<a href="{{o_url}}/{{o.id}}?report_comment={{i.id}}#report">أبلغ</a>
							</span>
						%end
					%end
				</div>
			</div>
		</div>
	%end
%end
</div>