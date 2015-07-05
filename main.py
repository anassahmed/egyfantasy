#_*_ coding: UTF-8 _*_
#!/usr/bin/python 
# main.py: the main file to direct urls.

from okasha.baseWebApp import *
from okasha.bottleTemplate import *

class vertEgyApp(baseWebApp):
	def __init__(self, *args, **kw):
		baseWebApp.__init__(self, *args, **kw)
	
	@expose(bottleTemplate, ['index.tpl'])
	def _root(self, rq, *args):
		return {'args':args, 'rq':rq}
	
	@expose(bottleTemplate, ['register.tpl'])
	def register(self, rq, *args):
		return {'args':args, 'rq':rq}
	
	@expose(bottleTemplate, ['activate.tpl'])
	def activate(self, rq, *args):
		return {'args':args, 'rq':rq}
	
	@expose(bottleTemplate, ['login.tpl'])
	def login(self, rq, *args):
		return {'args':args, 'rq':rq}
	@expose(bottleTemplate, ['user.tpl'])
	def user(self, rq, *args):
		return {'args':args, 'rq':rq}
	
if __name__ == "__main__":
	from paste import httpserver
	import os, os.path, sys

	d = os.path.dirname(sys.argv[0])
	app = vertEgyApp(os.path.join(d, 'templates'), 
		staticBaseDir={'/files/':os.path.join(d, 'files'),
		'/css/':os.path.join(d, 'files', 'css'),
		'/scripts/':os.path.join(d, 'files','scripts'),
		'/images/':os.path.join(d, 'files', 'images')})
	httpserver.serve(app, host="127.0.0.1", port=8080)