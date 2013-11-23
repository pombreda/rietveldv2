# Makefile to simplify some common AppEngine actions.
# Use 'make help' for a list of commands.

# Helper code to detect SDK location
define DETECT_SDK
import os
locations = [
  "../google_appengine",
  "/usr/local/google_appengine",
  ".locally/google_appengine",
]
for path in locations:
  if os.path.exists(path):
    print(path)
    break
endef
# /Helper

APPID?="testfoo-codereview"

SDK_PATH ?= $(shell python -c '$(DETECT_SDK)')

DEV_APPSERVER?= $(if $(SDK_PATH), $(SDK_PATH)/,)dev_appserver.py
DEV_APPSERVER_FLAGS?=

APPCFG?= $(if $(SDK_PATH), $(SDK_PATH)/,)appcfg.py
APPCFG_FLAGS?=

VERSION_TAG=`git describe --all --long --dirty | sed 's+heads/++' | sed 's+_+--+g'`

PYTHON?= python2.7
COVERAGE?= coverage


default: help

help:
	@echo "Available commands:"
	@sed -n '/^[a-zA-Z0-9_.]*:/s/:.*//p' <Makefile | sort

run: serve

serve: update_revision
	@echo "---[Starting SDK AppEngine Server]---"
	$(DEV_APPSERVER) $(DEV_APPSERVER_FLAGS) .

serve_remote: update_revision
	$(DEV_APPSERVER) $(DEV_APPSERVER_FLAGS) --host 0.0.0.0  --admin_host 0.0.0.0 .

serve_email: update_revision
	$(DEV_APPSERVER) $(DEV_APPSERVER_FLAGS) --enable_sendmail .

serve_remote_email: update_revision
	$(DEV_APPSERVER) $(DEV_APPSERVER_FLAGS) --enable_sendmail --host 0.0.0.0 --admin_host 0.0.0.0 .

update_revision:
	@echo "---[Updating REVISION]---"
	@echo "$(VERSION_TAG)" >REVISION

update: update_revision mapreduce update_backend
	@echo "---[Updating $(APPID)]---"
	$(APPCFG) $(APPCFG_FLAGS) update . --oauth2 --application $(APPID) --version $(VERSION_TAG)

update_backend: update_revision mapreduce
	@echo "---[Updating backend $(APPID)]---"
	$(APPCFG) $(APPCFG_FLAGS) backends update . --oauth2 --application $(APPID) --version $(VERSION_TAG)

upload: update

deploy: update

update_indexes:
	$(APPCFG) $(APPCFG_FLAGS) update_indexes . --oauth2 --application $(APPID)

vacuum_indexes:
	$(APPCFG) $(APPCFG_FLAGS) vacuum_indexes . --oauth2 --application $(APPID)

test:
	$(PYTHON) tests/run_tests.py $(SDK_PATH)

coverage:
	$(COVERAGE) run --branch tests/run_tests.py $(SDK_PATH)
	$(COVERAGE) html --include="codereview/*"

# Checkout mapreduce library and apply a little patch.
# See https://code.google.com/p/appengine-mapreduce/issues/detail?id=174
mapreduce:
	svn co -r 491 http://appengine-mapreduce.googlecode.com/svn/trunk/python/src/mapreduce
	cd mapreduce/ && patch < ../mapreduce.patch
