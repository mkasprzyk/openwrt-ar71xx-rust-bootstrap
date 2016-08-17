UNAME = $(shell uname)
LOCAL_WORKSPACE = build

PACKAGE_FINGERPRINT = 'Cargo.toml'
PACKAGE = $(shell find . -name ${PACKAGE_FINGERPRINT} -not -path "${LOCAL_WORKSPACE}/*" -exec dirname {} +)

IMAGE = openwrt-ar71xx-rust-bootstrap
DOCKER = $(shell which docker)
DOCKER_WORKSPACE = /build

CARGO_OPTS =

TARGET=mips-unknown-linux-musl
BUILD_CMD = "cd ${DOCKER_WORKSPACE} && cargo build --target=${TARGET} ${CARGO_OPTS}"

check:
	@if [ -z ${PACKAGE} ]; then echo "UNABLE TO FIND Cargo PACKAGE" && exit 1; fi

toolchain:
	${DOCKER} build -t ${IMAGE} .

build_linux: 
	@cp -fr ${PACKAGE} ${LOCAL_WORKSPACE}
	@cp -fr .cargo ${LOCAL_WORKSPACE}
	${DOCKER} run -v ${LOCAL_WORKSPACE}:${DOCKER_WORKSPACE} ${IMAGE} bash -c ${BUILD_CMD}

build_osx: build_clean 
	${DOCKER} run -d --name build ${IMAGE} bash -c "while true; do echo NOP && slepp 1; done"
	${DOCKER} cp ${PACKAGE} build:${DOCKER_WORKSPACE}
	${DOCKER} cp .cargo 	build:${DOCKER_WORKSPACE}
	${DOCKER} exec build bash -c ${BUILD_CMD}
	${DOCKER} cp build:${DOCKER_WORKSPACE} .

build_clean:
	@${DOCKER} kill build | true 
	@${DOCKER} rm   build | true

ifeq ($(UNAME), Darwin)
build: check build_osx
endif
ifeq ($(UNAME), Linux)
build: check build_linux
endif
