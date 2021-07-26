# git checkout source && 
hexo g && \cp -r public /tmp && 
\git checkout master && cp -r /tmp/public/* . && 
\git add . && git commit -m 'upate' && git push