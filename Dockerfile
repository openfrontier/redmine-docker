FROM sameersbn/redmine
MAINTAINER mengzhaopeng <qiuranke@gmail.com>

add ./redmine_agile /home/redmine/redmine/plugins/redmine_agile
RUN chown -R redmine:redmine /home/redmine/redmine/plugins/redmine_agile
