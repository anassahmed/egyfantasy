#_*_ coding: UTF-8 _*_
#!/usr/bin/python

from elixir import *
import datetime

SQL_SERVER = "localhost"
SQL_DB = "egyfantasy"
SQL_USER = "anass"
SQL_PASSWORD = "password"
SQL_PREFIX = "db_"

metadata.bind = "mysql://%s:%s@%s/%s" %(SQL_USER, SQL_PASSWORD, SQL_SERVER, SQL_DB)

class site_info(Entity):
	""" for general porposes, some information about our website """

	using_options(tablename = SQL_PREFIX + 'site_info')

	name = Field(Unicode(30))
	value = Field(UnicodeText)

class users(Entity):
	""" the main information about user """

	using_options(tablename = SQL_PREFIX + 'users')

	username = Field(Unicode(20), index = True, unique = True, required = True)
	password = Field(UnicodeText)
	email = Field(Unicode(60), index = True, unique = True)
	first_name = Field(Unicode(60), index = True)
	second_name = Field(Unicode(60), index = True)
	state = Field(Unicode(50))
	description = Field(Unicode(258))
	party = ManyToOne('party')
	is_admin = Field(Integer)
	is_banned = Field(Integer)
	ban_reason = Field(UnicodeText)
	is_active = Field(Integer)
	active_hash = Field(UnicodeText)
	user_meta = OneToMany('user_meta')
	sessions = OneToMany('sessions')
	notices = OneToMany('notice')
	topics = OneToMany('topic')
	mails = ManyToMany('mail')
	subscriptions = ManyToMany('subscriptions')
	notifications = ManyToMany('notifications')
	reports = OneToMany('reports')
	mentions = ManyToMany('mentions')
	reads = OneToMany('reads')


class user_meta(Entity):
	""" the optional information about users """

	using_options(tablename = SQL_PREFIX + 'user_meta')

	name = Field(Unicode(30), index = True)
	value = Field(UnicodeText)
	user = ManyToOne('users')

class login_attempts(Entity):
	""" for security """

	using_options(tablename = SQL_PREFIX + 'login_attempts')

	ip_address = Field(Unicode(100), index = True)
	time = Field(DateTime)
	attempts_number = Field(Integer)

class sessions(Entity):
	""" for secure login and logout """

	using_options(tablename = SQL_PREFIX + 'sessions')

	user = ManyToOne('users')
	beginnig_time = Field(DateTime, default = datetime.datetime.now())
	ending_time = Field(DateTime)
	session_hash = Field(UnicodeText)
	is_cookie = Field(Integer)
	ip_address = Field(Unicode(100), index = True)

class party(Entity):
	""" the main information about the party """

	using_options(tablename = SQL_PREFIX + 'party')

	page_name = Field(Unicode(30), index = True, unique = True)
	name = Field(Unicode(100), index = True)
	members = OneToMany('users')

class notice(Entity):
	""" for notices, like statuses in facebook, tweets in twitter, dents in identi.ca """

	using_options(tablename = SQL_PREFIX + 'notice')

	text = Field(Unicode(500))
	time = Field(DateTime, default = datetime.datetime.now())
	user = ManyToOne('users')
	party = ManyToOne('party')
	comments = OneToMany('comment')
	tags = ManyToMany('tags')
	mentions = OneToMany('mentions')
	reports = OneToMany('reports')
	subscriptions = OneToMany('subscriptions')
	is_red = OneToMany('reads')

class topic(Entity):
	""" for topics, like notes in facebook, blogs in wordpress and bloggers """

	using_options(tablename = SQL_PREFIX + 'topic')

	title = Field(Unicode(200), index = True)
	text = Field(UnicodeText)
	time = Field(DateTime, default = datetime.datetime.now())
	user = ManyToOne('users')
	party = ManyToOne('party')
	comments = OneToMany('comment')
	reports = OneToMany('reports')
	subscriptions = OneToMany('subscriptions')
	is_red = OneToMany('reads')

class mail(Entity):
	""" for PM messages between users """

	using_options(tablename = SQL_PREFIX + 'mail')

	from_user = Field(Integer)
	to_users = ManyToMany('users')
	subject = Field(Unicode(200), index = True, required = True)
	text = Field(UnicodeText)
	time = Field(DateTime, default = datetime.datetime.now())
	comments = OneToMany('comment')
	subscriptions = OneToMany('subscriptions')
	is_red = OneToMany('reads')

class comment(Entity):
	""" for comments on notices, topics and emails """

	using_options(tablename = SQL_PREFIX + 'comment')

	user = ManyToOne('users')
	notice = ManyToOne('notice')
	topic = ManyToOne('topic')
	mail = ManyToOne('mail')
	text = Field(UnicodeText)
	time = Field(DateTime, default = datetime.datetime.now())
	reports = OneToMany('reports')

class reports(Entity):
	""" for user, notice, topic and comment reports """

	using_options(tablename = SQL_PREFIX + 'reports')

	who_reported = Field(Integer)
	user = ManyToOne('users')
	party = ManyToOne('party')
	notice = ManyToOne('notice')
	topic = ManyToOne('topic')
	comment = ManyToOne('comment')
	report_text = Field(UnicodeText, required = True)

class subscriptions(Entity):
	"""for notifications """

	using_options(tablename = SQL_PREFIX + 'subscriptions')

	user_followed = Field(Integer)
	party_followed = Field(Integer)
	notice = ManyToOne('notice')
	topic = ManyToOne('topic')
	email = ManyToOne('mail')
	users = ManyToMany('users')

class notifications(Entity):
	""" like notifications in facebook """

	using_options(tablename = SQL_PREFIX + 'notifications')

	user = ManyToMany('users')
	type = Field(Unicode(50))
	object = Field(Unicode(50))
	parent = Field(Integer)
	notice = ManyToOne('notice')
	topic = ManyToOne('topic')
	time = Field(DateTime, default = datetime.datetime.now())
	is_red = OneToMany('reads')

class tags(Entity):
	""" hashtags for notices like hashtags in twitter """

	using_options(tablename = SQL_PREFIX + 'tags')

	name = Field(Unicode(30), index = True, unique = True)
	notices = ManyToMany('notice')

class mentions(Entity):
	""" @username mentions """

	using_options(tablename = SQL_PREFIX + 'mentions')

	who_mentioned = Field(Integer)
	user = ManyToMany('users')
	notice = ManyToOne('notice')

class reads(Entity):
	""" for red notices, topics, mails and notifications """

	using_options(tablename = SQL_PREFIX + 'reads')

	user = ManyToOne('users')
	notice = ManyToOne('notice')
	topic = ManyToOne('topic')
	notifications = ManyToOne('notifications')
	mails = ManyToOne('mail')
	is_red = Field(Integer)
