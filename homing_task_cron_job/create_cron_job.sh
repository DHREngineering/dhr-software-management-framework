#!/bin/bash

# Install the required Python package
sudo apt install python3-pika

# Define the cron job
CRON_JOB="0 21 * * * /usr/bin/python3 /home/dhr/dhr-software-management-framework/homing_task_cron_job/send_homing_task.py"

# Add the cron job to the current crontab
(crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -
