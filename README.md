
docker build -t enact:dockeravr-vm --target dockeravr-vm .

Before you run the simulation, you need to create a directory containing your simu & hex files (file.simu and file.hex)
Then from this directory you can execute the command :

docker run -it -v ${PWD}:/tmp/ enact:dockeravr-vm

A file out.json containing the logs of the execution is created in your directory.