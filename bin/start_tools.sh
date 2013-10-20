#!/bin/bash

for i in 1 2; do
  echo "Starting Resque worker $i"
  rake resque:work 2>&1 > log/resque_$i.log &
done
