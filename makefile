dev_up:
	docker-compose up --detach --remove-orphans

dev_down:
	docker-compose down --remove-orphans

dev_reload: dev_down dev_up
	

dev_ffmpeg_sh:
	docker-compose exec ffmpeg sh

dev_nginx_sh:
	docker-compose exec nginx bash

dev_sh:
	docker-compose exec nginx_ffmpeg sh


ff_nginx:
	nginx -g "daemon off;"

ff_stri:
	sh stream_image.sh

ff_strv:
	sh stream_video.sh

ff_pip1:
	sh stream_pip1.sh

ff_pip2:
	sh stream_pip2.sh

ff_ls:
	ls -la /tmp/hls

ff_rm:
	rm -rf /tmp/hls/*
