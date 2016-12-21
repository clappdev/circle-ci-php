#build image - az src mappával egy szinten kell futtatni
docker build -t clapp/circle-ci-php .

# project container run
docker run --name circle-ci-php -p 80:80 --link mysql:db -v ${PWD}:/usr/share/nginx/html -v /data/node_modules -d clapp/circle-ci-php

# NPM install container run, ezt a project src mappájában kell lefuttatni
docker run --rm -it -v ${PWD}:/data --volumes-from circle-ci-php creever/nodejs-grunt-npm-bower npm install

# GRUNT futtatása
docker run --rm -it -v ${PWD}:/data --volumes-from circle-ci-php creever/nodejs-grunt-npm-bower grunt

# ARTISAN VAGY COMPOSET futtatása - SRC mappában kell lenni
docker run --rm -it --link mysql:db -v ${PWD}:/app creever/clapp-php-cli php artisan ....

# MYSQL futtatása KITEMATICBAN A LEGEGYSZERŰBB
MYSQL_ROOT_PASSWORD-ot meg kell neki adni.
