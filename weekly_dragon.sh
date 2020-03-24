#!/bin/sh
#set -x
#メッセージを保存する一時ファイル
WEEKLY_JSON=$(mktemp -t readyjson)
trap "
rm ${WEEKLY_JSON}
" 0

# 日付大小比較
# arg1:'yyyy/mm/dd'
# arg2:'yyyy/mm/dd'
# 1が2より大きい場合、 +の数値を $ret に入れる
# 1が2より小さい場合、 -の数値を $ret に入れる
# 1が2と同じ大きさの場合、0 を $retに入れる
function dateComp()
{
    # 1970/01/01からの経過秒に変換
    ARG1_SECOND=`date -j -f "%Y-%m-%d" "$1" '+%s'`
    ARG2_SECOND=`date -j -f "%Y-%m-%d" "$2" '+%s'`

    # 差を返却
    expr $ARG1_SECOND - $ARG2_SECOND
}

##################
# Bakclog設定
##################

. ./.backlogenv

echo "【dragon征伐状況-Weekly】"
##################
# BAcklog APIコール
##################

STARTDATE=2019-12-01
ENDDATE=

if [ -z ${ENDDATE} ]; then
    ENDDATE=`date '+%Y-%m-%d'`
fi 

SINCEDATE=$STARTDATE
while [ 1 ] ; do

        # 処理
        RESULT_COMP=$(dateComp ${SINCEDATE} ${ENDDATE})
        if [ ${RESULT_COMP} -ge 0 ] ; then
                break
        fi

        UNTILDATE=`date -v+7d -j -f "%Y-%m-%d" "$SINCEDATE" "+%Y-%m-%d"`
        curl -o ${WEEKLY_JSON} "https://ardito-isg.backlog.com/api/v2/issues/count?apiKey=${BACKLOG_APIKEY}&projectId%5B%5D=${BACKLOG_PROJECTID}&issueTypeId%5B0%5D=${BACKLOG_TYPEID}&createdSince=${SINCEDATE}&createdUntil=${UNTILDATE}" > /dev/null 2>&1
        WEEKLY_NUM=$(cat ${WEEKLY_JSON} | sed -e 's/^{//' -e 's/}$//g' | cut -d ':' -f 2)
        echo "${SINCEDATE} : ${WEEKLY_NUM}"

        SINCEDATE=${UNTILDATE}
done
