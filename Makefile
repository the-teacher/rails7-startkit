# make APP="rake --vesion"
# make APP="rake db:create"
DOCKER = docker exec -w /home/lucky/app rails7app-rails-1 /bin/bash -c

all:
	${DOCKER} "${APP}"
