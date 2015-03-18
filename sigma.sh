#! /bin/bash
killall -9 ruby
nohup rails -e production -p 32000 &
