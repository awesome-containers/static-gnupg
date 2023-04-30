# Statically linked GnuPG

* **GnuPG** `2.4.1`
* **Libgpg-error** `1.47`
* **Libgcrypt** `1.10.2`
* **Libassuan** `2.5.5`
* **Libksba** `1.6.3`
* **nPth** `1.6`
* **Pinentry** `1.2.1`

---

Statically linked [GnuPG] container image with [Bash]

> ~ 29M (1,1M bash)

```bash
ghcr.io/awesome-containers/static-gnupg:latest
ghcr.io/awesome-containers/static-gnupg:2.4.1

docker.io/awesomecontainers/static-gnupg:latest
docker.io/awesomecontainers/static-gnupg:2.4.1
```

Slim statically linked [GnuPG] container image with [Bash]
packaged with [UPX]

> ~ 16M (578K bash)

```bash
ghcr.io/awesome-containers/static-gnupg:latest-slim
ghcr.io/awesome-containers/static-gnupg:2.4.1-slim

docker.io/awesomecontainers/static-gnupg:latest-slim
docker.io/awesomecontainers/static-gnupg:2.4.1-slim
```

[GnuPG]: https://gnupg.org/
[Bash]: https://github.com/awesome-containers/static-bash
[UPX]: https://upx.github.io/

<!--
```bash
image="localhost/${PWD##*/}"

podman build -t "$image:latest" .
podman build -t "$image:latest-slim" -f Containerfile-slim \
  --build-arg STATIC_GNUPG_IMAGE="$image" \
  --build-arg STATIC_GNUPG_VERSION=latest .

echo "$image:latest"
podman inspect "$image:latest" | jq '.[].Size' | numfmt --to=iec
echo "$image:latest-slim"
podman inspect "$image:latest-slim" | jq '.[].Size' | numfmt --to=iec

```
-->
