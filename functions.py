#_*_ coding: UTF-8 _*_
#!/usr/bin/python
# functions.py: important functions for our website.

from db import *
from okasha import baseWebApp
from recaptcha.client import captcha
from sqlalchemy import *
import datetime, random, urllib, hashlib, re, bitly
import smtplib

from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText


setup_all()

#functions controls urls inherited from Okasha.baseWebApp

fileNotFoundException = baseWebApp.fileNotFoundException
forbiddenException = baseWebApp.forbiddenException
redirectException = baseWebApp.redirectException
escape = baseWebApp.escape

# functions for date and time

now = datetime.datetime.now

def arstrftime(time):
	""" return string arabic date and time """

	days = [u'الاثنين', u'الثلاثاء', u'الأربعاء', u'الخميس', u'الجمعة', u'السبت', u'الأحد']
	months = [u'يناير', u'فبراير', u'مارس', u'أبريل', u'مايو', u'يونيو', u'يوليو', u'أغسطس', u'سبتمبر', u'أكتوبر', u'نوفمبر', u'ديسمبر']

	m_str = u'%s، %d %s %d %s' %(days[int(time.strftime('%u'))-1], time.day, months[time.month-1], time.year, time.strftime('%r'))
	m_str = m_str.replace(u'PM', u'م')
	m_str = m_str.replace(u'AM', u'ص')

	return m_str

# functions for main site info 

def get_site_url():
	""" retruns string for site url, eg: 'http://localhost:8080' """

	s = site_info.get_by(name = u'site_address').value
	return s

def get_relative_user_url(rq, user):
	""" returns string for relative user page url, eg: '/user/AnassAhmed/' """

	s = rq.script+'/user/'+user.username.encode('utf8')
	return s

# functions deals with users database

def get_user_by_name(username):
	""" get user by his user name
	returns User Entity Object """

	usr = users.get_by(username = username)
	return usr

def get_full_name(user):
	""" return full name of user """

	f_name = user.first_name.encode('utf8') + " " + user.second_name.encode('utf8')
	return f_name

def get_avatar(user, size = 200):
	""" return link of the avatar photo """
	
	mail_hash = hashlib.md5(user.email).hexdigest()
	avatar_link = "http://www.gravatar.com/avatar/%s.png?d=mm&s=%d" %(mail_hash, size)
	return avatar_link

def get_user_meta(user, name):
	""" return user_meta Entity Object or None"""

	m = user_meta.query.filter_by(user = user, name = name).first()
	return m

def get_user_meta_stwith(user, startswith):
	""" return user_meta List or None """

	m = user_meta.query.filter_by(user = user).filter(user_meta.name.startswith(startswith)).all()
	return m

#functions for registration

submit_captcha = captcha.submit

def is_username_valide(username):
	""" return boolean """

	m = re.match('^[a-zA-Z0-9]+$', username)
	if m == None:
		return False
	else:
		return True

def get_active_hash():
	""" returns unicode string """

	while True:
		random_hash = hashlib.sha256(str(random.randint(00000, 99999)).decode('utf8')).hexdigest().decode('utf8')
		usr_rand = users.get_by(active_hash = random_hash)
		if usr_rand == None:
			break
	return random_hash

def send_activate_msg(user):
	""" send a message by email """

	from_addr = site_info.get_by(name = u"site_mail").value
	to_addr = user.email
	full_name = get_full_name(user).decode('utf8')
	active_hash = user.active_hash
	link = site_info.get_by(name = u'site_address').value

	f_msg = MIMEMultipart('alternative')
	f_msg['Subject'] = u"الخيال المصري - رسالة التفعيل"
	f_msg['From'] = from_addr
	f_msg['To'] = to_addr

	text = u"""
	مرحبًا بك %s .. 
	لقد قمت بتسجيل عضوية في موقع "الخيال المصري"، من فضلك انسخ الرابط التالي والصقه في متصفحك لتُفعَّل عضويتك:
	%s/activate/%s 
	إذا لم تقم بالتسجيل في موقعنا، فضلًا تجاهل هذه الرسالة.
	وشكرًا جزيلًا.
	إدارة موقع الخيال الصمري""" %(full_name, link, active_hash)

	html = u"""
	<html>
		<head></head>
		<body>
		<h1 style="text-align:center;">رسالة التفعيل</h1>
		<p>مرحبًا بك %s,</p>
		<p>لقد قمت بتسجيل عضويتك في موقع "الخيال المصري"، من فضلك قم باتباع الرابط التالي لتفعيل عضويتك:</p>
		<a href="%s/activate/%s">اضغط هنا</a>
		<p>إذا لم تقم بالتسجيل في موقعنا، فضلًا تجاهل هذه الرسالة.</p>
		<p>وشكرًا جزيلًا.</p>
		<p style="text-align:center;"><b>إدارة موقع الخيال الصمري</b></p>
		</body>
	</html>""" %(full_name, link, active_hash)

	part1 = MIMEText(text.encode('utf8'), 'plain')
	part2 = MIMEText(html.encode('utf8'), 'html')

	f_msg.attach(part1)
	f_msg.attach(part2)

	s = smtplib.SMTP('localhost')
	s.sendmail(from_addr, to_addr, f_msg.as_string())
	s.close()

#functions for processing texts
def filter_text_html(t):
	if t == None:
		t = ""
	t = escape(t)
	t = t.splitlines()
	t = ('<br />').join(t)
	return t

def filter_text_html_js(t):
	if t == None:
		t = ""
	t = t.splitlines()
	t = escape(('<br />').join(t), quote = True)
	t = t.replace("'", "\\'")
	return t

def filter_text_notice(t):
	if t == None:
		t = ""
	t = t.splitlines()
	t = escape((' ').join(t), quote = True)
	t = t.replace("'", "&#39;")
	return t

def filter_en(t):
	t = t.lower()
	t = t.replace(" ", "")
	return t

def urlencode(url): 
	return urllib.quote(url)

def return_hash_sha256(text):
	return hashlib.sha256(text).hexdigest()

def return_hash_md5(text):
	return hashlib.md5(text).hexdigest()

def shorten_url(url):
	""" shorten url via bit.ly services """

	bitly_l = site_info.get_by(name = u'bitly_login_user').value.encode('utf8')
	bitly_key = site_info.get_by(name = u'bitly_api_key').value.encode('utf8')
	api = bitly.Api(login = bitly_l, apikey = bitly_key)
	short_url = api.shorten(url)
	return short_url

#functions for login and logout

def verify_attempt(ip_address):
	attempt = login_attempts.get_by(ip_address = ip_address.decode('utf8'))
	if attempt == None:
		new_attempt = login_attempts(ip_address = ip_address.decode('utf8'), time = datetime.datetime.now(), attempts_number = 0)
		session.commit()
		return 0
	if attempt != None:
		now = datetime.datetime.now()
		p = datetime.timedelta(minutes = 15)
		if attempt.time <= now - p:
			attempt.attempts_number = 0
		return attempt.attempts_number

def increase_attempt(ip_address):
	attempt = login_attempts.get_by(ip_address = ip_address.decode('utf8'))
	attempt.attempts_number += 1
	attempt.time = datetime.datetime.now()
	session.commit()


def whoLoggedin(rq):
	"""returns the user who logged in on None if there's no user logged in"""

	CN = "egyFantasyCookie"
	if not rq.cookies.has_key(CN):
		return None
	if rq.cookies.has_key(CN):
		s_hash = rq.cookies[CN].value.decode('utf8')
		sn = sessions.get_by(session_hash = s_hash)
		if sn == None:
			rq.response.setCookie(CN, '', 0)
			return None
		else:
			now = datetime.datetime.now()
			period = datetime.timedelta(minutes = 15)
			if sn.is_cookie: period = datetime.timedelta(weeks = 2)
			if sn.ending_time <= now:
				rq.response.setCookie(CN, '', 0)
				return None
			else:
				return sn.user

def increaseSession(rq):
	""" increases login period if the page reactivated """

	CN = "egyFantasyCookie"
	if whoLoggedin(rq) != None:
		s_hash = rq.cookies[CN].value.decode('utf8')
		sn = sessions.get_by(session_hash = s_hash)
		now = datetime.datetime.now()
		period = datetime.timedelta(minutes = 30)
		c_period = 30*60
		if sn.is_cookie:
			period = datetime.timedelta(weeks = 2)
			c_period = 60*60*24*14
		sn.ending_time = now + period
		session.commit()
		rq.response.setCookie(CN, s_hash, c_period)
		return True
	else:
		return False

# functions for notices
def filter_notice(t, rq):
	""" return True if notice text less than or equal to 140 characters, else: return False """
	t = filter_text_notice(t)
	url_re = re.compile(
	    r'https?://' # http:// or https://
	    r'(?:(?:[A-Z0-9](?:[A-Z0-9-]{0,61}[A-Z0-9])?\.)+[A-Z]{2,6}\.?|' #domain...
	    r'localhost|' #localhost...
	    r'\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})' # ...or ip
	    r'(?::\d+)?' # optional port
	    r'(?:/?|/\S+)', re.IGNORECASE)
	#short_url before counting characters in the notice!
	urls = url_re.findall(t)
	url_20 = []
	url_no_20 = []
	users_list = []
	tags_list = []
	for i in urls:
		if len(i) > 20:
			url_20.append(i)
		else:
			url_no_20.append(i)
	sh_links = len(url_20)
	twl = t
	if sh_links > 0:
		for i in url_20:
			twl.replace(i, u'')
	c = (sh_links * 20) + len(twl)
	if c <= 140:
		# validate mentions ...
		m = re.findall(u'@[a-zA-Z0-9]* ', t)
		if len(m) > 0:
			for i in m:
				user = users.get_by(username = i.replace(u'@', u''))
				if user == None:
					return -1
					break
				t = t.replace(i, u'<a dir="ltr" class="ltr" href="'+rq.script+u'/user/'+user.username+u'">'+i.replace(u' ', '')+u'</a> ')
				users_list.append(user)
		m = re.findall(u' #[a-zA-Z0-9]*', t)
		if len(m) > 0:
			for i in m:
				t = t.replace(i, u'<a dir="ltr" class="ltr" href="'+rq.script+u'/tag/'+i.replace(u'#', u'')+u'">'+i.replace(u' ','')+u'</a> ')
				tags_list.append(i.replace(u"#", u""))
		if sh_links > 0:
			for i in url_20:
				short_url = shorten_url(i.encode('utf8')).decode('utf8')
				t = t.replace(i, u'<a dir="ltr" href="'+short_url+u'">'+short_url+u'</a>')
		if len(url_no_20) > 0:
			for i in url_no_20:
				t = t.replace(i, u'<a dir="ltr" href="'+i+u'">'+i+u'</a>')
		return {'t':t, 'users':users_list, 'tags':tags_list}
	else:
		return 0 
	

def get_last_user_notices(user, l = 5, p = 1):
	""" get last notices for a specefic user, returns a list of Entity Objects """

	o = (l * p) - l
	ln = notice.query.filter(or_(notice.user == user, notice.mentions.any(mentions.user.any(id = user.id)))).order_by(desc(notice.time)).limit(l).offset(o).all()
	return ln

def get_user_notices_count(user):
	""" return long number """

	ln = notice.query.filter(or_(notice.user == user, notice.mentions.any(mentions.user.any(id = user.id)))).count()
	return ln

def get_notice(id):
	""" get notice info by id, returns an Entity Object or None """

	n = notice.get_by(id = id)
	return n

# functions for topics

def get_last_user_topics(user, l = 5, p =1):
	""" get last notices for a specific user, returns list of Entity Objects """

	o = (l * p) - l
	lt = topic.query.filter_by(user = user).order_by(desc(topic.time)).limit(l).offset(o).all()
	return lt

def get_user_topics_count(user):
	""" return long number """

	tc = topic.query.filter_by(user = user).count()
	return tc

def get_topic(id):
	""" return Entity Object """

	t = topic.get_by(id = id)
	return t

def get_first_part(t, letter_count):
	""" return (letter_count) letters (or less) string """

	if t == None:
		t = ""
	m = re.findall(u'<(.*?|/.*?)>', t)
	for i in m:
		t = t.replace(u'<'+i+u'>', u'')
	t = t.splitlines()
	t = ' '.join(t)
	t = t.replace('<br />', ' ')
	if len(t) > letter_count:
		t = t[:letter_count]
		sp = t.rfind(' ')
		t = t[:sp]
		t += u' ...'

	return t