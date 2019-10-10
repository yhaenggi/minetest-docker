#!/bin/bash
MINETEST_VERSION="$(cat MINETEST_VERSION)"
OPENGFX_VERSION="$(cat OPENGFX_VERSION)"
ARCHES="$(cat ARCHES)"
REGISTRY="$(cat REGISTRY)"

for arch in $ARCHES; do
	docker build -t ${REGISTRY}minetest-${arch}:${MINETEST_VERSION} --build-arg MINETEST_VERSION=${MINETEST_VERSION} --build-arg OPENGFX_VERSION=${OPENGFX_VERSION} --build-arg ARCH=${arch} .
done

for arch in $ARCHES; do
	docker push -t ${REGISTRY}minetest-${arch}:${MINETEST_VERSION}
done

manifests=""
for arch in $ARCHES; do
	manifests+="${REGISTRY}minetest-${arch}:${MINETEST_VERSION} "
done

docker manifest create ${REGISTRY}minetest:${MINETEST_VERSION} $manifests
docker manifest push --purge ${REGISTRY}minetest:${MINETEST_VERSION}
