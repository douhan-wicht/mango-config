#!/etc/profiles/per-user/douhan/bin/bash

ps aux | grep -v grep |grep dimland | grep -v idle | awk '{print $2}' | xargs kill
