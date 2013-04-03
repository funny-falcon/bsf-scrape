#!/bin/bash
# Proper header for a Bash script.

# This script is for the production environment.

#nice -n10 ionice -c2 -n5 /usr/local/bin/python2.7 /home/doppler/webapps/scripts_doppler/dopplervalueinvesting/delay.py

#nice -n10 ionice -c2 -n5 /usr/local/bin/python2.7 /home/doppler/webapps/scripts_doppler/dopplervalueinvesting/screen.py

#nice -n10 ionice -c2 -n5 /usr/local/bin/python2.7 /home/doppler/webapps/scripts_doppler/dopplervalueinvesting/stock.py

#/home/doppler/webapps/bargainstockfunds/gems

DIR_PWD="/home/doppler/webapps/bsf/gems"
export PATH=$DIR_PWD/bin:$PATH
export GEM_HOME=$DIR_PWD/gems
export RUBYLIB=$DIR_PWD/lib

gem1.9 install nokogiri
gem1.9 install pg -- --with-pg-config=/usr/pgsql-9.1/bin/pg_config

ruby /home/doppler/webapps/bsf_scrape/bsf-scrape/scrape.rb
