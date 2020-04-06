
docker build -t enact:dockeravr-vm --target dockeravr-vm .

docker run -it -v blink.simu:/tmp/file.simu -v blink.hex:/tmp/file.hex enact:dockeravr-vm
