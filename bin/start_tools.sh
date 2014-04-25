#!/bin/bash

for i in 1 2; do
  echo "Starting Resque worker $i"
  QUEUE="*" bundle exec rake resque:work 2>&1 > log/resque_$i.log &
done
