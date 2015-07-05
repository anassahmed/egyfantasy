
<a name="main"></a>
<h2>الرئيسية</h2>
%include user_notices args=args, rq=rq, usr=usr
<a href="{{rq.script}}/user/{{usr.username}}/notices/#notice"><button id="moreNotices">المزيد</button></a>
<div class="clear"></div>
%include user_topics args=args, rq=rq, usr=usr
<a href="{{rq.script}}/user/{{usr.username}}/topics/#topic"><button id="moreNotices">المزيد</button></a>