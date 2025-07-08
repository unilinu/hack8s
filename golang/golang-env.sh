set -ex

SHELL_RUN_CONF=~/.zshrc

echo 'export GOROOT=/usr/local/go' >> $SHELL_RUN_CONF
echo 'export GOPATH=$HOME/go' >> $SHELL_RUN_CONF
echo 'export PATH=$PATH:$GOROOT/bin:$GOPATH/bin' >> $SHELL_RUN_CONF

go env -w GO111MODULE=on

set +x
