#!/usr/bin/env bash
SEIMI_HOME=$(cd `dirname $0`; cd ..; pwd)
#https://github.com/rudimeier/bash_ini_parser
function read_ini()
{
    S_SECTION=$2; S_ITEM=$3
        # Be strict with the prefix, since it's going to be run through eval
    function check_prefix()
    {
        if ! [[ "${VARNAME_PREFIX}" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]] ;then
            echo "read_ini: invalid prefix '${VARNAME_PREFIX}'" >&2
            return 1
        fi
    }
    function check_ini_file()
    {
        if [ ! -r "$INI_FILE" ] ;then
            echo "read_ini: '${INI_FILE}' doesn't exist or not" \
                "readable" >&2
            return 1
        fi
    }
    # enable some optional shell behavior (shopt)
    function pollute_bash()
    {
        if ! shopt -q extglob ;then
            SWITCH_SHOPT="${SWITCH_SHOPT} extglob"
        fi
        if ! shopt -q nocasematch ;then
            SWITCH_SHOPT="${SWITCH_SHOPT} nocasematch"
        fi
        shopt -q -s ${SWITCH_SHOPT}
    }
    # unset all local functions and restore shopt settings before returning
    # from read_ini()
    function cleanup_bash()
    {
        shopt -q -u ${SWITCH_SHOPT}
        unset -f check_prefix check_ini_file pollute_bash cleanup_bash
    }
    local INI_FILE=""
    local INI_SECTION=""
    # {{{ START Deal with command line args

    # Set defaults
    local BOOLEANS=1
    local VARNAME_PREFIX=INI
    local CLEAN_ENV=0

    # {{{ START Options

    # Available options:
    #    --boolean        Whether to recognise special boolean values: ie for 'yes', 'true'
    #                    and 'on' return 1; for 'no', 'false' and 'off' return 0. Quoted
    #                    values will be left as strings
    #                    Default: on
    #
    #    --prefix=STRING    String to begin all returned variables with (followed by '__').
    #                    Default: INI
    #
    #    First non-option arg is filename, second is section name
    while [ $# -gt 0 ]
    do
        case $1 in
            --clean | -c )
                CLEAN_ENV=1
            ;;
            --booleans | -b )
                shift
                BOOLEANS=$1
            ;;
            --prefix | -p )
                shift
                VARNAME_PREFIX=$1
            ;;
            * )
                if [ -z "$INI_FILE" ]
                then
                    INI_FILE=$1
                else
                    if [ -z "$INI_SECTION" ]
                    then
                        INI_SECTION=$1
                    fi
                fi
            ;;
        esac
        shift
    done
    if [ -z "$INI_FILE" ] && [ "${CLEAN_ENV}" = 0 ] ;then
        echo -e "Usage: read_ini [-c] [-b 0| -b 1]] [-p PREFIX] FILE"\
            "[SECTION]\n  or   read_ini -c [-p PREFIX]" >&2
        cleanup_bash
        return 1
    fi
    if ! check_prefix ;then
        cleanup_bash
        return 1
    fi
    local INI_ALL_VARNAME="${VARNAME_PREFIX}__ALL_VARS"
    local INI_ALL_SECTION="${VARNAME_PREFIX}__ALL_SECTIONS"
    local INI_NUMSECTIONS_VARNAME="${VARNAME_PREFIX}__NUMSECTIONS"
    if [ "${CLEAN_ENV}" = 1 ] ;then
        eval unset "\$${INI_ALL_VARNAME}"
    fi
    unset ${INI_ALL_VARNAME}
    unset ${INI_ALL_SECTION}
    unset ${INI_NUMSECTIONS_VARNAME}
    if [ -z "$INI_FILE" ] ;then
        cleanup_bash
        return 0
    fi
    if ! check_ini_file ;then
        cleanup_bash
        return 1
    fi
    # Sanitise BOOLEANS - interpret "0" as 0, anything else as 1
    if [ "$BOOLEANS" != "0" ]
    then
        BOOLEANS=1
    fi
    # }}} END Options
    # }}} END Deal with command line args
    local LINE_NUM=0
    local SECTIONS_NUM=0
    local SECTION=""
    # IFS is used in "read" and we want to switch it within the loop
    local IFS=$' \t\n'
    local IFS_OLD="${IFS}"
    # we need some optional shell behavior (shopt) but want to restore
    # current settings before returning
    local SWITCH_SHOPT=""
    pollute_bash
        TARGET_VAR=${VARNAME_PREFIX}__${S_SECTION}__${S_ITEM}
    while read -r line || [ -n "$line" ]
    do
        ((LINE_NUM++))
        # Skip blank lines and comments
        if [ -z "$line" -o "${line:0:1}" = ";" -o "${line:0:1}" = "#" ]
        then
            continue
        fi
        # Section marker?
        if [[ "${line}" =~ ^\[[a-zA-Z0-9_]{1,}\]$ ]]
        then
            # Set SECTION var to name of section (strip [ and ] from section marker)
            SECTION="${line#[}"
            SECTION="${SECTION%]}"
            eval "${INI_ALL_SECTION}=\"\${${INI_ALL_SECTION}# } $SECTION\""
            ((SECTIONS_NUM++))
            continue
        fi
        # Are we getting only a specific section? And are we currently in it?
        if [ ! -z "$INI_SECTION" ]
        then
            if [ "$SECTION" != "$INI_SECTION" ]
            then
                continue
            fi
        fi
        # Valid var/value line? (check for variable name and then '=')
        if ! [[ "${line}" =~ ^[a-zA-Z0-9._]{1,}[[:space:]]*= ]]
        then
            echo "Error: Invalid line:" >&2
            echo " ${LINE_NUM}: $line" >&2
            cleanup_bash
            return 1
        fi
        # split line at "=" sign
        IFS="="
        read -r VAR VAL <<< "${line}"
        IFS="${IFS_OLD}"

        # delete spaces around the equal sign (using extglob)
        VAR="${VAR%%+([[:space:]])}"
        VAL="${VAL##+([[:space:]])}"
        VAR=$(echo $VAR)
        # Construct variable name:
        # ${VARNAME_PREFIX}__$SECTION__$VAR
        # Or if not in a section:
        # ${VARNAME_PREFIX}__$VAR
        # In both cases, full stops ('.') are replaced with underscores ('_')
        if [ -z "$SECTION" ]
        then
            VARNAME=${VARNAME_PREFIX}__${VAR//./_}
        else
            VARNAME=${VARNAME_PREFIX}__${SECTION}__${VAR//./_}
        fi
        eval "${INI_ALL_VARNAME}=\"\${${INI_ALL_VARNAME}# } ${VARNAME}\""

        if [[ "${VAL}" =~ ^\".*\"$  ]]
        then
            # remove existing double quotes
            VAL="${VAL##\"}"
            VAL="${VAL%%\"}"
        elif [[ "${VAL}" =~ ^\'.*\'$  ]]
        then
            # remove existing single quotes
            VAL="${VAL##\'}"
            VAL="${VAL%%\'}"
        elif [ "$BOOLEANS" = 1 ]
        then
            # Value is not enclosed in quotes
            # Booleans processing is switched on, check for special boolean
            # values and convert
            # here we compare case insensitive because
            # "shopt nocasematch"
            case "$VAL" in
                yes | true | on )
                    VAL=1
                ;;
                no | false | off )
                    VAL=0
                ;;
            esac
        fi
        # enclose the value in single quotes and escape any
        # single quotes and backslashes that may be in the value
        VAL="${VAL//\\/\\\\}"
        #VAL="\$'${VAL//\'/\'}'"
        if [[ $VARNAME = $TARGET_VAR ]]
        then
            echo "${VAL}"
            break
        fi
    done  <"${INI_FILE}"
    cleanup_bash
}
function usage(){
cat<<EOF
SeimiCrawler service helper
usage: run.sh [options]
       start          start service
       stop           stop service
       help           Print service help
EOF
exit 0
}
function start(){
    JAVA_CMD=`which java`
    if [ ! -x "$JAVA_CMD" ]; then
        JAVA_CMD="$JAVA_HOME/bin/java"
    fi
    if [ ! -x "$JAVA_CMD" ]; then
        echo "Can not find JAVA_HOME in sys env."
    fi
    SEIMI_CLASS_PATH=".:$SEIMI_HOME/seimi/classes/:$SEIMI_HOME/seimi/lib/*"
    SEIMI_SYS_ARGS="-Dfile.encoding=UTF-8"
    # e.g. SEIMI_CRAWLER_ARGS="-c basic -p 8080" 这里指定要启动的Crawler的name，若第一个参数为数字则认为是启动该端口号的内置http服务接受http接口发送过来的Request
    SEIMI_CRAWLER_ARGS="$(read_ini $SEIMI_HOME/bin/seimi.cfg init_cfg params)"
    SEIMI_STDOUT=($(read_ini $SEIMI_HOME/bin/seimi.cfg linux stdout))
    nohup $JAVA_CMD -cp $SEIMI_CLASS_PATH $SEIMI_SYS_ARGS cn.wanghaomiao.seimi.boot.Run $SEIMI_CRAWLER_ARGS >$SEIMI_STDOUT 2>&1 &
    PID=`echo $!`
    if [ -d "/proc/$PID" ]; then
        echo $!>"$SEIMI_HOME/.seimicrawler.lock.pid"
        echo "[Info]SeimiCrawler started,pid: $PID"
    else
        echo "[Error]SeimiCrawler start failed ,you can see more info in $SEIMI_STDOUT."
    fi
    exit 0
}

function stop(){
	if [ -f "$SEIMI_HOME/.seimicrawler.lock.pid" ]; then
		echo "SeimiCrawler pid file is ok."
	else
		echo "No SeimiCrawler instance is alive,home dir: $SEIMI_HOME"
		exit 0
	fi
	pid=$(cat $SEIMI_HOME/.seimicrawler.lock.pid)
	if [ ! -d "/proc/$pid" ]; then
		echo "No SeimiCrawler instance is running,pid:$pid"
		rm "$SEIMI_HOME/.seimicrawler.lock.pid"
		exit 0
	else
		kill $pid
		if [ $? -eq 0 ]; then
			echo "Stop current SeimiCrawler instance,pid:$pid"
			rm "$SEIMI_HOME/.seimicrawler.lock.pid"
			exit 0
		else
			echo "Stop current SeimiCrawler instance failed,pid:$pid"
		fi
	fi
	rm "$SEIMI_HOME/.seimicrawler.lock.pid"
	exit 0
}
for arg ;do
    case "$arg" in
        help) usage ;;
        start) start;;
        stop) stop;;
    esac
done

usage