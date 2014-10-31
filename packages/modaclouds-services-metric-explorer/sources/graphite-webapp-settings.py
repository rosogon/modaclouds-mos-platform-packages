
import os
import os.path

SECRET_KEY = os.environ['GRAPHITE_WEBAPP_KEY']

ALLOWED_HOSTS = [ '*' ]
TIME_ZONE = 'UTC'

LOG_RENDERING_PERFORMANCE = True
LOG_CACHE_PERFORMANCE = True
LOG_METRIC_ACCESS = True

DEBUG = True

GRAPHITE_ROOT = os.environ['GRAPHITE_ROOT']
CONF_DIR = os.environ['GRAPHITE_CONF_DIR']
STORAGE_DIR = os.environ['GRAPHITE_STORAGE_DIR']
CONTENT_DIR = os.environ['GRAPHITE_WEBAPP_CONTENT_DIR']

DASHBOARD_CONF = os.path.join (os.environ['GRAPHITE_WEBAPP_CONF_DIR'], "dashboard.conf")
GRAPHTEMPLATES_CONF = os.path.join (os.environ['GRAPHITE_WEBAPP_CONF_DIR'], "graphtemplates.conf")

WHISPER_DIR = os.path.join (STORAGE_DIR, 'whisper')
DATA_DIRS = [ WHISPER_DIR ]
LOG_DIR = os.path.join (STORAGE_DIR, 'log/webapp')
INDEX_FILE = os.path.join (STORAGE_DIR, 'index')

DATABASES = {
	'default' : {
		'NAME' : os.path.join (STORAGE_DIR, 'webapp.db'),
		'ENGINE' : 'django.db.backends.sqlite3',
		'USER' : '',
		'PASSWORD' : '',
		'HOST' : '',
		'PORT' : ''
	}
}
