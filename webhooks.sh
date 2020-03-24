#!/bin/sh
#set -x
#メッセージを保存する一時ファイル
MESSAGEFILE=$(mktemp -t webhook)
READY_JSON=$(mktemp -t readyjson)
DOING_JSON=$(mktemp -t doingjson)
DONE_JSON=$(mktemp -t donejson)
CLOSE_JSON=$(mktemp -t closejson)
trap "
rm ${MESSAGEFILE}
rm ${READY_JSON}
rm ${DOING_JSON}
rm ${DONE_JSON}
rm ${CLOSE_JSON}
" 0

##################
#Slack設定
##################
. ./.slackenv

##################
# Bakclog設定
##################

. ./.backlogenv

##################
# BAcklog APIコール
##################
BACKLOG_STATUSID=1
curl -o ${READY_JSON} "https://ardito-isg.backlog.com/api/v2/issues/count?apiKey=${BACKLOG_APIKEY}&projectId\[\]=${BACKLOG_PROJECTID}&issueTypeId\[\]=${BACKLOG_TYPEID}&statusId\[\]=${BACKLOG_STATUSID}"
READY_NUM=$(cat ${READY_JSON} | sed -e 's/^{//' -e 's/}$//g' | cut -d ':' -f 2)

BACKLOG_STATUSID=2
curl -o ${DOING_JSON} "https://ardito-isg.backlog.com/api/v2/issues/count?apiKey=${BACKLOG_APIKEY}&projectId\[\]=${BACKLOG_PROJECTID}&issueTypeId\[\]=${BACKLOG_TYPEID}&statusId\[\]=${BACKLOG_STATUSID}"
DOING_NUM=$(cat ${DOING_JSON} | sed -e 's/^{//' -e 's/}$//g' | cut -d ':' -f 2)

BACKLOG_STATUSID=3
curl -o ${DONE_JSON} "https://ardito-isg.backlog.com/api/v2/issues/count?apiKey=${BACKLOG_APIKEY}&projectId\[\]=${BACKLOG_PROJECTID}&issueTypeId\[\]=${BACKLOG_TYPEID}&statusId\[\]=${BACKLOG_STATUSID}"
DONE_NUM=$(cat ${DONE_JSON} | sed -e 's/^{//' -e 's/}$//g' | cut -d ':' -f 2)

BACKLOG_STATUSID=4
curl -o ${CLOSE_JSON} "https://ardito-isg.backlog.com/api/v2/issues/count?apiKey=${BACKLOG_APIKEY}&projectId\[\]=${BACKLOG_PROJECTID}&issueTypeId\[\]=${BACKLOG_TYPEID}&statusId\[\]=${BACKLOG_STATUSID}"
CLOSE_NUM=$(cat ${CLOSE_JSON} | sed -e 's/^{//' -e 's/}$//g' | cut -d ':' -f 2)

##################
# Text
##################
echo "【dragon征伐状況】" > ${MESSAGEFILE}
echo "未対応・・・${READY_NUM}" >> ${MESSAGEFILE}
echo "処理中・・・${DOING_NUM}" >> ${MESSAGEFILE}
echo "処理済み・・${DONE_NUM}" >> ${MESSAGEFILE}
echo "完了・・・・${CLOSE_NUM}" >> ${MESSAGEFILE}

WEBMESSAGE=`cat ${MESSAGEFILE}`

##################
# Slack APIコール
##################
#cat  ${DOING_JSON}
curl -XPOST -d "token=${WEBTOKEN}" -d "channel=${CHANNEL}" -d "username=${BOTNAME}" -d "icon_emoji=${FACEICON}" -d "text=${WEBMESSAGE}"  'https://slack.com/api/chat.postMessage'
