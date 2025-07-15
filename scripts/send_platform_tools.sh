#!/bin/bash

ssh -T root@192.168.7.2 "mkdir -p software"
scp -T -r software/platform root@192.168.7.2:./software
scp -T software/defines.h root@192.168.7.2:./software
