#_*_ coding: UTF-8 _*_
#!/usr/bin/python
# setup.py: nessecary steps for starting my web app.

from db import *
import hashlib

######## EDIT THIS ##########

SITE_ADDRESS = u"http://localhost:8080"
SITE_MAIL = u"SITE_MAIL"
RECAPTCHA_PRIVATE_KEY = u"RECAPTCHA_PRIVATE_KEY"
RECAPTCHA_PUBLIC_KEY = u"RECAPTCHA_PRIVATE_KEY"
BITLY_LOGIN_USER = u"BITLY_LOGIN_USER"
BITLY_API_KEY = u"BITLY_API_KEY"
ADMIN_USERNAME = u"anass"
ADMIN_PASSWORD = hashlib.sha256(u"ADMIN_PASSWORD").hexdigest().decode('utf8')
ADMIN_MAIL = u"ADMIN_MAIL"
ADMIN_FIRSTNAME = u"أنس"
ADMIN_SECONDNAME = u"أحمد"
ADMIN_STATE = u"الجيزة"
ADMIN_DESCRIPTION = u"مبرمج بايثون، مستخدم جنو/لينوكس. طالب أزهري."

######### DON'T EDIT AFTER THIS ##########

print "Egyfnatasy_setup: connecting with database ..."

setup_all()

print "Egyfnatasy_setup: creating the tables ..."

create_all()

print "Egyfnatasy_setup: inserting site information ..."

site_address = site_info(name = u"site_address", value = SITE_ADDRESS)
site_mail = site_info(name = u"site_mail", value = SITE_MAIL)
recaptcha_public_key = site_info(name = u"recaptcha_public_key", value = RECAPTCHA_PUBLIC_KEY)
recaptcha_private_key = site_info(name = u"recaptcha_private_key", value = RECAPTCHA_PRIVATE_KEY)
bitly_login_user = site_info(name = u"bitly_login_user", value = BITLY_LOGIN_USER)
bitly_api_key = site_info(name = u"bitly_api_key", value = BITLY_API_KEY)

#TODO: Put reCAPTCHA keys in the db.

#print "Egyfnatasy_setup: inserting admin information ..."

#admin = users(username = ADMIN_USERNAME, password = ADMIN_PASSWORD, email = ADMIN_MAIL, first_name = ADMIN_FIRSTNAME, second_name = ADMIN_SECONDNAME, state = ADMIN_STATE, description = ADMIN_DESCRIPTION, is_admin = 1, is_active = 1)

print "Egyfnatasy_setup: saving to db ..."

session.commit()

print "Egyfnatasy_setup: SETUP IS DONE :)"
