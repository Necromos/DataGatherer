#! /bin/bash
killall -9 ruby
nohup bin/rails s -e production -p 32000 &
