## 👋 Welcome to rarbg 🚀  

A self-hosted Torznab API for the RARBG backup, compatible with Prowlarr, Radarr, Sonarr etc.
  
From: <https://github.com/mgdigital/rarbg-selfhosted>
  
## Run container

```shell
docker run -d \
--name casjaysdevdocker-rarbg \
-v "$HOME/.local/share/srv/docker/rarbg/rootfs/config":/config \
-v "$HOME/.local/share/srv/docker/rarbg/rootfs/data":/data \
-p 3333:3333 \
casjaysdevdocker/rarbg
```
  
  
## Install my system scripts  

```shell
 sudo bash -c "$(curl -q -LSsf "https://github.com/systemmgr/installer/raw/main/install.sh")"
 sudo systemmgr --config && sudo systemmgr install scripts  
```

## Get source files  

```shell
dockermgr download src casjaysdevdocker/rarbg
```

OR

```shell
git clone "https://github.com/casjaysdevdocker/rarbg" "$HOME/Projects/github/casjaysdevdocker/rarbg"
```

## Build container  

```shell
cd "$HOME/Projects/github/casjaysdevdocker/rarbg"
buildx 
```

## Authors  

🤖 casjay: [Github](https://github.com/casjay) 🤖  
⛵ casjaysdevdocker: [Github](https://github.com/casjaysdevdocker) [Docker](https://hub.docker.com/r/casjaysdevdocker) ⛵  
