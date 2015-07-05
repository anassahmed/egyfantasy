# -*- coding: utf-8 -*-
import sys, os, os.path
d = os.path.dirname(__file__)
sys.path.append(d)
from main import vertEgyApp
application=vertEgyApp(
  os.path.join(d,'templates'),
  staticBaseDir={'/files/':os.path.join(d,'files'), 
  '/images/':os.path.join(d, 'files', 'images'), 
  '/scripts/':os.path.join(d, 'files', 'scripts'), 
  '/css/':os.path.join(d, 'files', 'css')}
);

