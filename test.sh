#!/bin/bash
set -e

DIR=`mktemp -d --tmpdir jamirdochegal-unittest-XXXXXXXX`

# setup colors
if tput sgr0 >/dev/null 2>&1; then
    RED=$(tput setaf 1)
    GREEN=$(tput setaf 2)
    YELLOW=$(tput setaf 3)
    WHITE=$(tput setaf 7)
    BOLD=$(tput bold)
    RESET=$(tput sgr0)
else
    RED=
    GREEN=
    YELLOW=
    WHITE=
    BOLD=
    RESET=
fi

status()
{
    echo "${BOLD}${YELLOW}>> ${@}${RESET}"
}

error_out()
{
    status "${RED}test script was interrupted"
    status "${RED}temporary directory \`$DIR' was not cleaned"
    status "${RED}investigate and delete at your leisure"
    trap '' ERR
    exit 1
}

trap error_out ERR

check_active()
{
    local NAME="$1" URL="$2"
    declare -g OK="$3" ERRORS="$4"

    rm -f $DIR/output
    set -- $(curl -o $DIR/output --location --silent --max-time 3 --write-out '%{http_code} %{time_pretransfer}' "$URL")
    local HTTP_STATUS="$1" HTTP_TIME="$2"
    
    if [ -e $DIR/output ]; then
	FILE_SIZE=$(stat -c %s $DIR/output)
    else
	FILE_SIZE=0
    fi

    # echo $HTTP_STATUS $HTTP_TIME $FILE_SIZE

    local ERROR
    case "$HTTP_STATUS" in
	200)
	    # OK
	    ;;

	000)
	    # no HTTP status - could be streaming mode or timeout
	    # check connection time and file size
	    if [ $HTTP_TIME = "0,000" ]; then
		ERROR=timeout
	    elif [ $FILE_SIZE -eq 0 ]; then
		ERROR=timeout
	    else
		ERROR=streaming
	    fi
	    ;;

	501)
	    ERROR=unsure
	    ;;

	*)
	    ERROR=error
	    ;;
    esac

    local COLOR
    case "$ERROR" in
	'')
	    let OK++ || true
	    COLOR="$GREEN"
	    ;;

	streaming)
	    let OK++ || true
	    COLOR="$YELLOW"
	    ERROR=" ($ERROR)"
	    ;;

	*)
	    let ERRORS++ || true
	    COLOR="$RED"
	    ERROR=" ($ERROR)"
	    ;;
    esac

    printf "${BOLD}${COLOR}%s${WHITE} : %s %s${RESET}\n" "${HTTP_STATUS}${ERROR}" "[$NAME]" "$URL"

    return 0
}

#################################################################


status 'checking jamirdochgal script syntax'
./jamirdochegal -l > $DIR/jamirdochegal_l_stdout 2> $DIR/jamirdochegal_l_stderr
./jamirdochegal -h > $DIR/jamirdochegal_h_stdout 2> $DIR/jamirdochegal_h_stderr
printf "${BOLD}${GREEN}OK ${WHITE} : script looks good${RESET}\n"


BROKEN=

status 'checking active stations'
OK=0
ERRORS=0

sed '1,/__DATA__/d;/^\s*#/d' jamirdochegal | grep http | (
    while read LINE; do
	NAME="${LINE%http*}"
	NAME="${NAME% *}"
	URL="${LINE/*http/http}"
	check_active "$NAME" "$URL" "$OK" "$ERRORS"
    done
    echo $OK > $DIR/ok
    echo $ERRORS > $DIR/errors
)

read OK < $DIR/ok
read ERRORS < $DIR/errors
if [ $ERRORS -gt 0 ]; then
    BROKEN=yes
fi
TOTAL=$(( OK + ERRORS ))
status "$TOTAL stations total, $OK ok, $ERRORS errors"


status 'checking inactive stations'
OK=0
ERRORS=0

sed '1,/__DATA__/d;/^\s*[^#]/d;s/^#\s*//' jamirdochegal | grep http | (
    while read NAME URL; do
	URL="${URL/*http/http}"
	check_active "$NAME" "$URL" "$OK" "$ERRORS"
    done
    echo $OK > $DIR/ok
    echo $ERRORS > $DIR/errors
)

read OK < $DIR/ok
read ERRORS < $DIR/errors
if [ $OK -gt 0 ]; then
    BROKEN=yes
fi
TOTAL=$(( OK + ERRORS ))
status "$TOTAL stations total, $ERRORS broken as expected, $OK unexpectedly ok"


#################################################################

status 'removing temporary directory'
rm -rf "$DIR"

if [ $BROKEN ]; then
    status "${RED}there were errors - unsuccessful exit"
    exit 1
else
    status "${GREEN}successful exit"
    exit 0
fi
