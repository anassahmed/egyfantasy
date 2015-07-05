<!-- user topics -->

%from db import *
%from functions import *
%setup_all()

<a name="topic"></a>
<span class="hidden" id="shortUrl" value=""></span>

%if len(args) == 2:
	<h2>المواضيع</h2>
%end

%t_title = ""
%t_text = ""
%usr_url = get_relative_user_url(rq, usr)

%if rq.q.has_key('addtopic'):
	%if whoLoggedin(rq) == usr:
		%if rq.q.getfirst('title','') != "" and rq.q.getfirst('topic_text') != "":
			%t = topic(title = escape(rq.q.getfirst('title','')).decode('utf8'), user = usr, time = now())
			%if int(rq.q.getfirst('no-js')):
				%t.text = filter_text_html(rq.q.getfirst('topic_text','').decode('utf8'))
			%else:
				%t.text = rq.q.getfirst('topic_text','').decode('utf8')
			%end
			%sub = subscriptions(topic = t, users = [whoLoggedin(rq)])
			%session.commit()
			<div class="note"><p>هنيئًا! لقد أُضيف موضوعك بنجاح. وسيتم تحويلك إليه خلال ثوان. إذا كان متصفحك لا يدعم الانتقال التلقائي <a href="{{usr_url}}/topics/{{t.id}}#topic">إضغط هنا</a>.</p></div>
			<head>
				<meta http-equiv="refresh" content="3; {{usr_url}}/topics/{{t.id}}#topic" />
			</head>
		%elif rq.q.getfirst('title','') == "":
			<div class="error"><p><strong>خطأ: </strong>لم تكتب عنوان الموضوع!</p></div>
			%t_text = rq.q.getfirst('topic_text','')
		%elif rq.q.getfirst('topic_text','') == "":
			<div class="error"><p><strong>خطأ: </strong>لم تكتب شيئًا في الموضوع!</p></div>
			%t_title = rq.q.getfirst('title','')
		%end
	%else:
		<div class="error"><p><strong>خطأ: </strong>لا يمكنك إضافة موضوع هنا!</p></div>
	%end
%elif rq.q.has_key('deletetopic') and rq.q.has_key('topic_id') and whoLoggedin(rq) == usr:
	%t = get_topic(rq.q.getfirst('topic_id'))
	%t.delete()
	%session.commit()
	<div class="note"><p>حُذِف الموضوع بنجاح!</p></div>
%end

%if whoLoggedin(rq) == usr and len(args) == 2:
	<script type="text/javascript">
	    var CKEDITOR_BASEPATH = "{{rq.script}}/scripts/ckeditor/";
	</script>
	<script type="text/javascript" src="{{rq.script}}/scripts/ckeditor/ckeditor.js"></script>
	<script type="text/javascript">
	$(document).ready(function() {
		var editor;
        function richText() {
            editor = CKEDITOR.replace('topic_text', {
            	language: 'ar',
            	toolbar: [
            		['Bold','Italic','Strike','-','Subscript','Superscript'],
				    ['NumberedList','BulletedList','-','Outdent','Indent','Blockquote'],
				    ['JustifyLeft','JustifyRight'],
				    ['BidiLtr', 'BidiRtl'],
				    ['Link','Unlink','Anchor'],
				    ['Image','Flash','Table','HorizontalRule','Smiley','SpecialChar'],
				    ['Format']
            	]
            });
        };
        function htmlText() {
            if (!editor) {return;}
            
            editor.destroy()
        };
        richText();
        $("#no-js").attr('value', '0');
   	})
	</script>
	<h3>أضف موضوعًا</h3>
	<form id="addTopic" name="addTopic" action="{{usr_url}}/topics/#topic" method="POST">
		<input type="hidden" id="addtopic" name="addtopic" value="1" />
		<input type="hidden" id="no-js" name="no-js" value="1" />
		<label for="title">عنوان الموضوع:</label>
		<input type="text" id="title" name="title" value="{{t_title}}" />
		<label for="topic_text">الموضوع:</label>
		<textarea id="topic_text" name="topic_text">
		{{t_text}}
		</textarea>
		<input type="button" id="rich" class="hidden" onClick="richText()" />
		<input type="submit" id="submitTopic" name="submitTopic" value="أضِف" />
	</form>
%end

<div class="clear"></div>

%if len(args) <= 2:
	<a name="latest-topics">
	<h3>آخر المواضيع</h3>
	</a>

	%if len(args) < 2:
		%l_topics = get_last_user_topics(usr)
	%elif rq.q.has_key('p'):
		%l_topics = get_last_user_topics(usr, 10, int(rq.q.getfirst('p')))
	%else:
		%l_topics = get_last_user_topics(usr, 10, 1)
	%end
	%t_count = get_user_topics_count(usr)
	%if t_count == 0:
		<div class="note"><p>هذا العضو لم يضِف بعدُ أية مواضيع.</p></div>
	%else:
		%for i in l_topics:
			%user_url = get_relative_user_url(rq, i.user)
			<div class="topicItem">
			<div class="meta" style="float: left; margin-top: 3px;">
				<span class="share"><label>شارك:</label>&nbsp;
					%fb_title = 'الخيال المصري | %s > %s' %(get_full_name(i.user), i.title.encode('utf8'))
					%tw_text = get_first_part(u'RT|%s %s' %(i.user.username, i.title), 118).encode('utf8')
					%link = get_site_url()+user_url.decode('utf8')+u'/topics/'+str(i.id).decode('utf8')
					<a href="javascript: void(0)" onClick="return fbs_click('{{link}}','{{fb_title}}')" ><img src="{{rq.script}}/images/facebook_share.png" alt="facebook" /></a>
					<a href="javascript: void(0)" onClick="short_url('{{link}}'); setTimeout(function() {tws_click(getShortUrl(),'{{tw_text}}')}, 2000)"><img src="{{rq.script}}/images/twitter_share.png" alt="twitter" /></a>
				</span>
			</div>
			<h4><a href="{{user_url}}/topics/{{i.id}}#viewTopic">{{i.title}}</a></h4>
			<a href="{{user_url}}/"><img class="avatar" src="{{get_avatar(i.user, 70)}}" alt="{{i.user.username}}" /></a>
			<a class="full_name" href="{{user_url}}/"><strong>{{get_full_name(i.user)}}</strong></a>
			<div class="topicText">
			{{!get_first_part(i.text, 255)}}
			<span class="readmore"><a href="{{user_url}}/topics/{{i.id}}#viewTopic">إقرأ المزيد</a></span>
			</div>
			<div class="meta">
				<span class="time"><a href="{{user_url}}/topics/{{i.id}}#viewTopic">{{arstrftime(i.time)}}</a></span>
				<span class="comments"><a href="{{user_url}}/topics/{{i.id}}#comments">{{len(i.comments)}} تعليقـ/ـات</a></span>
				%if whoLoggedin(rq) != None:
					%if whoLoggedin(rq) == i.user:
						<span class="delete">
						<a href="{{user_url}}/topics/{{i.id}}/delete/#delete">احذف</a>
						</span>
					%else:
						<span class="report">
						<a href="{{user_url}}/topics/{{i.id}}/report/#report">أبلغ</a>
						</span>
					%end
				%end
			</div>
			</div>
		%end
		%if len(args) == 2:
			%if t_count > 10:
				<div id="pages">
				%pn = t_count / 10
				%if t_count % 10 != 0:
					%pn += 1
				%end 
				%pn += 1
				%for i in range(1, pn):
					<a class="round" href="{{usr_url}}/topics/?p={{i}}#latest-topics">{{i}}</a>
				%end
				</div>
			%end
		%end
	%end
%else:
	%t = get_topic(id = args[2])
	%user_url = get_relative_user_url(rq, t.user)
	%if t.user != usr:
		%raise fileNotFoundException()
	%end
	%if len(args) > 3 and args[3] == 'delete':
		%if whoLoggedin(rq) == t.user:
			<a name="delete"></a>
			<div class="note" id="delete">
				<p>هل تريد حقًا حذف هذا الموضوع؟</p>
			<form id="deleteTopic" name="deleteTopic" action="{{user_url}}/topics/#latest-topics" method="POST">
				<input type="hidden" id="deletetopic" name="deletetopic" value="1" />
				<input type="hidden" id="topic_id" name="topic_id" value="{{t.id}}" />
				<input type="submit" id="submit" name="submit" value="احذف" />
				<a href="{{user_url}}/topics/{{t.id}}#viewTopic">
				<input type="button" id="cancel" name="cancel" value="ألغِ" /></a>
			</form>
			</div>
		%else:
			<div class="error"><p><strong>خطأ: </strong>لا تملك الصلاحيات الكافية لحذف هذا الموضوع.</p></div>
		%end
	%elif len(args) > 3 and args[3] == 'report':
		%form = True
		%r = reports.query.filter_by(topic = t).filter_by(who_reported = whoLoggedin(rq).id).first()
		%if whoLoggedin(rq) == usr or whoLoggedin(rq) == None or r != None:
			%raise forbiddenException()
		%else:
			%if rq.q.has_key('reason'):
				%if len(t.reports) == 10:
					%for i in t.comments:
						%i.delete()
					%end
					%t.delete()
					%session.commit()
				%else:
					%r = reports(topic = t, who_reported = whoLoggedin(rq).id, report_text = escape(rq.q.getfirst('reason').decode('utf8')))
				%end
				%session.commit()
				<a name="report"></a>
				<div class="note"><p>لقد أُرسِلَ إبلاغك، وسيراجع بواسطة الإدارة.</p></div>
				%form = False
			%end
			%if form:
				<a name="report"></a>
				<h3>أبلغ عن موضوع</h3>
				<form id="reportUser" name="reportUser" action="{{user_url}}/topics/{{t.id}}/report/#report" method="POST">
					<p>
					<label for="username">الموضوع المراد الإبلاغ عنه:</label>
					<span id="username">{{t.title}}</span>
					</p>
					<p>
					<label for="reason">سبب الإبلاغ:</label>
					<textarea id="reason" name="reason" style="width:98%;"></textarea>
					</p>
					<div class="clear"></div>
					<div style="float:left;">
					<input type="submit" id="submit" name="submit" value="أبلغ" />
					<a href="{{user_url}}/topics/#latest-topics"><input type="button" value="ألغِ" /></a>
					</div>
					<div class="clear"></div>
				</form>
			%end
		%end
	%end
	<a name="viewTopic"></a>
	<div class="viewTopic">
	<div class="meta" style="float: left; margin-top: -3px;">
		<span class="share"><label>شارك:</label>&nbsp;
			%fb_title = 'الخيال المصري | %s > %s' %(get_full_name(t.user), t.title.encode('utf8'))
			%tw_text = get_first_part(u'RT|%s %s' %(t.user.username, t.title), 118).encode('utf8')
			%link = get_site_url()+user_url.decode('utf8')+u'/topics/'+str(t.id).decode('utf8')
			<a href="javascript: void(0)" onClick="return fbs_click('{{link}}','{{fb_title}}')" ><img src="{{rq.script}}/images/facebook_share.png" alt="facebook" /></a>
			<a href="javascript: void(0)" onClick="short_url('{{link}}'); setTimeout(function() {tws_click(getShortUrl(),'{{tw_text}}')}, 2000)"><img src="{{rq.script}}/images/twitter_share.png" alt="twitter" /></a>
		</span>
	</div>
	<h2>{{t.title}}</h2>
	<a href="{{user_url}}/"><img class="avatar" src="{{get_avatar(t.user, 100)}}" alt="{{t.user.username}}" /></a>
	<a class="full_name" href="{{user_url}}/"><strong>{{get_full_name(t.user)}}</strong></a>
	<div class="topicText">
	{{!t.text}}
	</div>
	<div class="meta">
		<span class="time"><a href="{{user_url}}/topics/{{t.id}}">{{arstrftime(t.time)}}</a></span>
		%if whoLoggedin(rq) != None:
			%if whoLoggedin(rq) == t.user:
				<span class="delete">
				<a href="{{user_url}}/topics/{{t.id}}/delete/#delete">احذف</a>
				</span>
			%else:
				<span class="report">
				<a href="{{user_url}}/topics/{{t.id}}/report/#report">أبلغ</a>
				</span>
			%end
		%end
	</div>
	</div>
	%include comments args=args, rq=rq, usr=usr, obj='topic', obj_id=t.id
%end