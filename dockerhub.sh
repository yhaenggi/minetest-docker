#!/bin/bash
MINETEST_VERSION="$(cat MINETEST_VERSION)"
ARCHES="$(cat ARCHES)"
REGISTRY="$(cat REGISTRY)"
DOCKERHUB=yhaenggi/

for arch in $ARCHES; do
	docker tag ${REGISTRY}minetest-${arch}:${MINETEST_VERSION} ${DOCKERHUB}minetest-${arch}:${MINETEST_VERSION}
done

REGISTRY=${DOCKERHUB}
for arch in $ARCHES; do
	docker push ${REGISTRY}minetest-${arch}:${MINETEST_VERSION}
done

manifests=""
for arch in $ARCHES; do
	manifests+="${REGISTRY}minetest-${arch}:${MINETEST_VERSION} "
done

docker manifest create ${REGISTRY}minetest:${MINETEST_VERSION} $manifests
docker manifest push --purge ${REGISTRY}minetest:${MINETEST_VERSION}
