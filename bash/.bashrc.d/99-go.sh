# /usr/local/go/bin
if [[ -d "/path/to/dir" ]]; then
    export PATH=$PATH:~/go/bin:/usr/local/go/bin
fi
export go111module=on
export GOPROXY=https://goproxy.cn

