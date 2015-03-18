#! /bin/bash
killall -9 ruby
nohup rails s -e production -p 32000 &
