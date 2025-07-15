#!/bin/bash

ssh -T root@192.168.7.2 "mkdir -p firmware"
scp -T -r $1 root@192.168.7.2:./firmware/$2
