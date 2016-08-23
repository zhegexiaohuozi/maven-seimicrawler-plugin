#!/bin/bash
#Modify from http://git.oschina.net/ipvb/ServiceLauncher
PrefixDir=$(cd `dirname $0`; pwd)
#echo $PrefixDir

function CheckSyntax()
{
	if [ ! -f $1 ];then
		return 1
	fi

	ret=$(awk -F= 'BEGIN{valid=1}
	{
		if(valid == 0) next
		if(length($0) == 0) next
		gsub(" |\t","",$0)
		head_char=substr($0,1,1)
		if (head_char != "#"){
			if( NF == 1){
				b=substr($0,1,1)
				len=length($0)
				e=substr($0,len,1)
				if (b != "[" || e != "]"){
					valid=0
				}
			}else if( NF == 2){
				b=substr($0,1,1)
				if (b == "["){
					valid=0
				}
			}else{
				valid=0
			}
		}
	}
	END{print valid}' $1)

	if [ $ret -eq 1 ];then
		return 0
	else
		return 2
	fi
}

function GetPrivateProfileString()
{
	if [ ! -f $1 ] || [ $# -ne 3 ];then
		return 1
	fi
	blockname=$2
	fieldname=$3

	begin_block=0
	end_block=0

	cat $1 | while read line
	do

		if [ "X$line" = "X[$blockname]" ];then
			begin_block=1
			continue
		fi

		if [ $begin_block -eq 1 ];then
			end_block=$(echo $line | awk 'BEGIN{ret=0} /^\[.*\]$/{ret=1} END{print ret}')
			if [ $end_block -eq 1 ];then
				#echo "end block"
				break
			fi

			need_ignore=$(echo $line | awk 'BEGIN{ret=0} /^#/{ret=1} /^$/{ret=1} END{print ret}')
			if [ $need_ignore -eq 1 ];then
				#echo "ignored line:" $line
				continue
			fi
			field=$(echo $line | awk -F= '{gsub(" |\t","",$1); print $1}')
			#####Fix Me We Support Space Value
			value=$(echo $line | awk -F= '{gsub("","",$2); print $2}')
			#echo "'$field':'$value'"
			if [ "X$fieldname" = "X$field" ];then
				#echo "result value:'$result'"
				echo $value
				break
			fi

		fi
	done
	return 0
}

function usage(){
cat<<EOF
SeimiCrawler launcher helper
usage: launcher [options]
       -start          start service
       -stop           stop service
       -status         check service run status
       -restart        restart service
       -help           Print service launcher help
EOF
exit 0
}

function ReadVMOptions(){
	if [ ! -f "$PrefixDir/seimi.vmoptions" ]; then
		echo "Not Found seimi.vmoptions in $PrefixDir"
		exit 1
	fi
	vmArgs=""
	while read oneline
	do
		if [ ! `echo $oneline |grep ^#` ]; then
			vmArgs="${vmArgs} $oneline"
		fi
	done <"$PrefixDir/seimi.vmoptions"
	echo $vmArgs
}

###
# PID Validity Checking
# PidValidityCheck $pid $bin
###
function PidValidityCheck(){
	mypid=$1
	vpid=`ps -ax | awk '{ print $1 }' | grep -e "^${mypid}$"`
	if [ ! -z $vpid ]; then
		echo "Not found Process ( PID: $mypid)"
		return 1
	fi
	selfbin= `readlink /proc/$2/exe`
	if [[ $2 == $selfbin ]]; then
		return 0
	else
		return 1
	fi
}

function stopSeimiCrawler()
{
	if [ -f "$PrefixDir/.seimi.launcher.lock.pid" ]; then
		echo "First,your pid lock file .seimi.launcher.lock.pid is exists"
	else
		echo "Not found .seimi.launcher.lock.pid in Service Root $PrefixDir"
		return 1;
	fi
	pid=$(cat $PrefixDir/.seimi.launcher.lock.pid)
	if [ ! -d "/proc/$pid" ]; then
		echo "Service Not running,pid:$pid"
		rm "$PrefixDir/.seimi.launcher.lock.pid"
		return 1;
	else
		kill $pid
		if [ $? -eq 0 ]; then
			echo "Kill Service process success,pid is $pid"
			rm "$PrefixDir/.seimi.launcher.lock.pid"
			return 0;
		else
			echo "Kill Service process failed,pid is $pid"
		fi
	fi
	rm "$PrefixDir/.seimi.launcher.lock.pid"
	return 1;
}

function startSeimiCrawler(){
	javabin=`which java`
	if [ ! -x "$javabin" ]; then
	    javabin="$JAVA_HOME/bin/java"
	fi
	if [ ! -x "$javabin" ]; then
		echo "Can not find JAVA_HOME in sys env."
	fi
	vmArgs=$(ReadVMOptions)
	serstdout=$(GetPrivateProfileString seimi.cfg Linux stdout)
	params=$(GetPrivateProfileString seimi.cfg StartCfg Params)
	seimiClassPath=.:$PrefixDir/../seimi/classes:$PrefixDir/../seimi/lib/*
	nohup $javabin $vmArgs -cp $seimiClassPath cn.wanghaomiao.seimi.boot.Run $params >$serstdout &
	javaId=`echo $!`
	if [ -d "/proc/$javaId" ]; then
		echo $!>"$PrefixDir/.seimi.launcher.lock.pid"
		echo "Start SeimiCrawler Success,pid: $javaId"
	else
		echo "Start $jarpkg Failed ,your should check $serstdout."
	fi
}

function Startup()
{
	echo "launcher script will start SeimiCrawler."
	startSeimiCrawler
	exit 0
}
###
function Stop()
{
	echo "launcher script will Stop SeimiCrawler."
	stopSeimiCrawler
	exit 0
}
##
function Restart()
{
	echo "launcher script will restart SeimiCrawler."
	stopSeimiCrawler
	if [ $? -eq "0" ]; then
		startSeimiCrawler
	else
		echo "Stop SeimiCrawler Failed."
	fi
	exit 0
}

function Status()
{
	echo "launcher check SeimiCrawler run status"
	if [ ! -f "$PrefixDir/.seimi.launcher.lock.pid" ]; then
		echo "Not found .seimi.launcher.lock.pid in SeimiCrawler Root $PrefixDir"
		exit 1
	fi
	pid=$(cat $PrefixDir/.seimi.launcher.lock.pid)
	if [ ! -d "/proc/$pid" ]; then
		echo "SeimiCrawler Not running,pid:$pid"
		rm "$PrefixDir/.seimi.launcher.lock.pid"
		exit 1
	else
		echo "SeimiCrawler Start Time:"
		ps -p $pid -o lstart
		echo "SeimiCrawler is running,status info>"
		cat "/proc/$pid/status"
	fi
	exit 0
}
for arg ;do
	case "$arg" in
		-help) usage ;;
		-start) Startup;;
		-stop) Stop;;
		-status) Status;;
		-restart) Restart;;
esac
done

usage