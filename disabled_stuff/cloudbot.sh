#!/bin/bash
echo ""
echo "   ________                ______        __ "
echo "  / ____/ /___  __  ______/ / __ )____  / /_"
echo " / /   / / __ \/ / / / __  / __  / __ \/ __/"
echo "/ /___/ / /_/ / /_/ / /_/ / /_/ / /_/ / /_  "
echo "\____/_/\____/\__,_/\__,_/_____/\____/\__/  "                                          
echo " http://git.io/cloudbotirc       by ClouDev "
echo ""
locatefiles() {
    botfile="/bot.py"
    botfile=$(pwd)$botfile
    logfile="/bot.log"
    logfile=$(pwd)$logfile
}

running() {
    if [[ $(ps aux|grep bot.py|grep -v grep|grep -v daemon|grep -v SCREEN) != "" ]]; then
        true
    else
        false
    fi
}

checkbackend() {
        if dpkg -l| grep ^ii|grep daemon|grep 'turns other' > /dev/null; then
            backend="daemon"
        elif dpkg -l| grep ^ii|grep screen|grep 'terminal multi' > /dev/null; then
            backend="screen"
        else
            backend="manual"
        fi
    return 0
}

setcommands() {
    status() {
        if running; then
            echo "CloudBot is running!"
        else
            echo "CloudBot is not running!"
        fi
    }
    clear() {
        : > $logfile
    }
    if [ "$backend" == "daemon" ]; then
        start() {
            daemon -r -n cloudbot -O $logfile python $botfile
        }
        stop() {
            daemon -n cloudbot --stop
        }
    elif [ "$backend" == "screen" ]; then
        start() {
            screen -d -m -S cloudbot -t cloudbot python $botfile > $logfile 2>&1
        }
        stop() {
            pid=`ps ax|grep -v grep|grep python|grep -v SCREEN|grep $botfile|awk '{print $1}'`
            kill $pid
        }
    elif [ "$backend" == "manual" ]; then
        start() {
            $botfile
        }
        stop() {
            pid=`ps ax|grep -v grep|grep python|grep $botfile|awk '{print $1}'`
            kill $pid
        }
    fi
}

processargs() {
    case $1 in
        start|-start|--start)
            if running; then
                echo "Cannot start! Bot is already running!"
                exit 1
            else
                echo "Starting CloudBot... ($backend)"
                start
            fi
        ;;
        stop|-stop|--stop)
            if running; then
                echo "Stopping CloudBot... ($backend)"
                stop
            else
                echo "Cannot stop! Bot is not already running!"
                exit 1
            fi
        ;;
        restart|-restart|--restart)
            if running; then
                echo "Restarting CloudBot... ($backend)"
                stop
                sleep 3
                start
            else
                echo "Cannot restart! Bot is not already running!"
                exit 1
            fi
        ;;
        clear|-clear|--clear)
            echo "Clearing logs..."
            clear
        ;;
        status|-status|--status)
            status
        ;;
        *)  
            usage="usage: ./cloudbot {start|stop|restart|clear|status}"
            echo $usage
        ;;
    esac
}

main() {
    locatefiles
    checkbackend
    setcommands
    processargs $1
}

main $*
exit 0