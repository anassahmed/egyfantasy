%from db import *
%from okasha.baseWebApp import *
%from functions import *

%setup_all()

%if whoLoggedin(rq) != usr:
	%raise forbiddenException()
%end

%if args:
	%if args[2] == 'exdata':
		%include user_settings_exdata args=args, rq=rq, usr=usr
	%elif args[2] == 'socials':
		%include user_settings_socials args=args, rq=rq, usr=usr
	%elif args[2] == 'avatar':
		%include user_settings_avatar args=args, rq=rq, usr=usr
	%elif args[2] == 'mdata':
		%include user_settings_mdata args=args, rq=rq, usr=usr
	%end
%end