<!-- edit social networks -->
%from db import *
%from functions import *
%setup_all()

<style type="text/css">
	form input[type=text] {
		width: 200px;
	}
</style>

<a name="socials"></a>
<h2>الشبكات الإجتماعية</h2>

%if rq.q.has_key('editsocials'):
	%if rq.q.has_key('facebook'):
		%facebook_meta = get_user_meta(usr, u'social_facebook')
		%facebook_m = u"http://www.facebook.com/"+escape(rq.q.getfirst('facebook','')).decode('utf8')
		%if facebook_meta == None:
			%facebook_meta = user_meta(user = usr, name = u"social_facebook", value = facebook_m)
		%else:
			%facebook_meta.value = facebook_m
		%end
	%end
	%if rq.q.has_key('twitter'):
		%twitter_meta = get_user_meta(usr, u'social_twitter')
		%twitter_m = u"http://www.twitter.com/"+escape(rq.q.getfirst('twitter','')).decode('utf8')
		%if twitter_meta == None:
			%twitter_meta = user_meta(user = usr, name = u"social_twitter", value = twitter_m)
		%else:
			%twitter_meta.value = twitter_m
		%end
	%end
	%if rq.q.has_key('identica'):
		%identica_meta = get_user_meta(usr, u'social_identica')
		%identica_m = u"http://www.identi.ca/"+escape(rq.q.getfirst('identica')).decode('utf8')
		%if identica_meta == None:
			%identica_meta = user_meta(user = usr, name = u"social_identica", value = identica_m)
		%else:
			%identica_meta.value = identica_m
		%end
	%end
	%session.commit()
	<div class="note"><p>هنيـــــئًا! لــقد حُفِظت تعديلاتك بنجاح.</p></div>
%end

<form id="editSocialNetworks" name="editSocialNetworks" action="{{rq.script}}/user/{{usr.username}}/settings/socials/#socials" method="POST">
<input type="hidden" id='editsocials' name="editsocials" value="1" />
<table>
<tr>
	%facebook = get_user_meta(usr, u'social_facebook')
	%if facebook != None:
		%f = facebook.value[24:]
	%else:
		%f = ""
	%end
	<td><label for="facebook">حساب فيس بوك:</label></td>
	<td class="ltr"><span>http://www.facebook.com/</span><input type="text" id="facebook" name="facebook" value="{{f}}" /></td>
</tr>
<tr>
	%twitter = get_user_meta(usr, u'social_twitter')
	%if twitter != None:
		%t = twitter.value[23:]
	%else:
		%t = ""
	%end
	<td><label for="twitter">حساب تويتر:</label></td>
	<td class="ltr"><span>http://www.twitter.com/</span><input type="text" id="twitter" name="twitter" value="{{t}}" /></td>
</tr>
<tr>
	%identica = get_user_meta(usr, u'social_identica')
	%if identica != None:
		%idca = identica.value[21:]
	%else:
		%idca = ""
	%end
	<td><label for="identica">حساب أيدينتيكا:</label></td>
	<td class="ltr"><span>http://www.identi.ca/</span><input type="text" class="ltr" id="identica" name="identica" value="{{idca}}" /></td>
</tr>
<tr>
	<td></td>
	<td><input type="submit" class="submit" id="submit" name="submit" value="حفظ" /></td>
</tr>
</table>
</form>