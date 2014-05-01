#!/bin/bash

kill `cat /data/fu2/shared/resqued.pid`
bundle exec resqued -p /data/fu2/shared/resqued.pid -l log/resque.log -D config/resqued.rb
