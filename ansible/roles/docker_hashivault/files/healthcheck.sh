#! /bin/sh

case $(wget -S http://127.0.0.1:8200/v1/sys/health 2>&1 | awk '/^  HTTP/{print $2}') in
    200|429|501|503)
        exit 0
    ;;
    *)
        exit 1
    ;;
esac
