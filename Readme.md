A blog servered by [hugo](https://gohugo.io/)

## Hugo version
```
hugo v0.151.0+extended+withdeploy darwin/arm64 BuildDate=2025-10-02T13:30:36Z VendorInfo=brew
```
## Install hugo with extend
```
// debian or ubuntu
sudo apt-get install hugo
// macOS
brew install hugo
```

## Run on local
```
git submodule update --init --recursive
git pull --recurse-submodules
hugo server -D
// or
sh server.sh
```

 [ ] Enable comment [gitalk](https://github.com/gitalk/gitalk).
 
 [ ] Deploy website on Cloudflare pages.