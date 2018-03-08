#!/bin/bash
set -x

# Config ECS agent
echo "ECS_CLUSTER=${ecs_cluster}" > /etc/ecs/ecs.config

# Stream instance logs to CloudWatch Logs
grep '/var/log/cfn-hup.log' /etc/awslogs/awslogs.conf
if [ $? -ne 0 ]; then

    INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
    LOG_GROUP="${log_group}"
    REGION=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | grep '\"region\"' | cut -d\" -f4)

    # install the awslogs package
    yum install -y aws-cli awslogs

    # update awscli.conf with regions where logs to be sent
    grep 'region = ' /etc/awslogs/awscli.conf
    if [ $? -ne 0 ]; then
        echo "region = $${REGION}" >> /etc/awslogs/awscli.conf
    else
        sed -i "s/region = .*/region = $${REGION}/g" /etc/awslogs/awscli.conf
    fi
    sed -i '/^\[\/var\/log\/messages\]/,+6 s/^/#/' /etc/awslogs/awslogs.conf

    # include app log file section in the awslogs.conf
    logfiles=("/var/log/cfn-hup.log" "/var/log/cfn-init.log" "/var/log/cfn-init-cmd.log" "/var/log/cloud-init.log" "/var/log/cloud-init-output.log" "/var/log/docker-events.log" "/var/log/docker"  "/var/log/healthd/daemon.log" "/var/log/cron" "/var/log/messages" "/var/log/yum.log")
    for logfile in "$${logfiles[@]}";
    do
        echo -e "\n[$${logfile}]\
        \nfile = $${logfile}\
        \nlog_group_name = $${LOG_GROUP}\
        \nlog_stream_name = $${INSTANCE_ID}_$${logfile}\
        \ninitial_position = start_of_file\
        \ndatetime_format = %b %d %H:%M:%S\
        \nbuffer_duration = 5000" >> /etc/awslogs/awslogs.conf
    done

    # Handle rotated files - filename with wildcard
    echo -e "\n[/var/log/ecs/ecs-init.log]\
    \nfile = /var/log/ecs/ecs-init.log.*\
    \nlog_group_name = $${LOG_GROUP}\
    \nlog_stream_name = $${INSTANCE_ID}_/var/log/ecs/ecs-init.log\
    \ninitial_position = start_of_file\
    \ndatetime_format = %b %d %H:%M:%S\
    \nbuffer_duration = 5000" >> /etc/awslogs/awslogs.conf

    echo -e "\n[/var/log/ecs/ecs-agent.log]\
    \nfile = /var/log/ecs/ecs-agent.log.*\
    \nlog_group_name = $${LOG_GROUP}\
    \nlog_stream_name = $${INSTANCE_ID}_/var/log/ecs/ecs-agent.log\
    \ninitial_position = start_of_file\
    \ndatetime_format = %b %d %H:%M:%S\
    \nbuffer_duration = 5000" >> /etc/awslogs/awslogs.conf

    # restart awslogs service
    service awslogs restart
    # enable awslogs service to start on system boot
    chkconfig awslogs on
fi

# Reclaim unused Docker disk space
cat << "EOF" > /usr/local/bin/claimspace.sh
#!/bin/bash
# Run fstrim on the host OS periodically to reclaim the unused container data blocks
docker ps -q | xargs docker inspect --format='{{ .State.Pid }}' | xargs -IZ sudo fstrim /proc/Z/root/
exit $?
EOF

chmod +x /usr/local/bin/claimspace.sh
echo "0 0 * * * root /usr/local/bin/claimspace.sh" > /etc/cron.d/claimspace

# Additional user data
${additional_user_data_script}
