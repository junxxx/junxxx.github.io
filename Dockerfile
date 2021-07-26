FROM node:14
WORKDIR /app
COPY . ./
RUN npm config set registry https://registry.npm.taobao.org \
&& npm install -g hexo-cli \
&& npm install hexo-renderer-pug --save \
&& npm install hexo-renderer-sass --save \
&& npm install
EXPOSE 4000
CMD hexo server -d -p 4000