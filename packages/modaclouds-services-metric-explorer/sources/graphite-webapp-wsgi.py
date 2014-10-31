
import os, os.path, sys

sys.path.append(os.environ['GRAPHITE_WEBAPP_ROOT'])

os.environ['DJANGO_SETTINGS_MODULE'] = 'graphite.settings'

import django.core.handlers.wsgi

application = django.core.handlers.wsgi.WSGIHandler()

import graphite.metrics.search
