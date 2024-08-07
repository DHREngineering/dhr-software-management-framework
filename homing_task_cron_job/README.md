# Run cron job to send a homing task to the robot-arm-orchestrator at midnight (21:00 UTC)

`./create_cron_job.sh`

ensure the cron job was created and there are no duplicates  
`crontab -l`

you can also manually edit the cron jobs with  
`crontab -e`
