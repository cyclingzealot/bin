#!/bin/bash

phpunit --stop-on-failure --configuration /home/jlam/code/ArtsandCultureCalendar/Symfony/app/phpunit.xml  && push.bash $1
