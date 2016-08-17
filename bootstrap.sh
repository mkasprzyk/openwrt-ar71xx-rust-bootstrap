#!/usr/bin/env bash

export SDK_ROOT=/sdk
export SDK_RELEASE=${1:-OpenWrt-SDK-ar71xx-generic_gcc-5.3.0_musl-1.1.14.Linux-x86_64.tar.bz2}
export RUST_RELEASE=${2:-nightly}

mkdir -p $SDK_ROOT

apt-get update
apt-get install -qq -y wget bzip2 curl cmake python2.7 libssl-dev

curl https://sh.rustup.rs -sSf | sh -s -- -y --default-toolchain $RUST_RELEASE

source $HOME/.cargo/env
rustup target add mips-unknown-linux-musl

cd /tmp
    wget -q https://downloads.openwrt.org/snapshots/trunk/ar71xx/generic/$SDK_RELEASE
    tar xjf $SDK_RELEASE --strip-components=1 -C $SDK_ROOT
cd -

cd /usr/bin
    for file in $(find $SDK_ROOT -name 'mips-openwrt-linux-musl-*'); do 
        ln -s $file $(basename $file | sed 's/openwrt/unknown/g')
    done
cd -

echo "export STAGING_DIR=$SDK_ROOT/staging_dir" >> ~/.bashrc
echo "source ~/.cargo/env" >> ~/.bashrc

