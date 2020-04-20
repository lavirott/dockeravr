###
# Build a simulide builder 
FROM debian:stable-slim AS simulide-builder
LABEL maintainer="Stéphane Lavirotte <stephane@lavirotte.com>"
WORKDIR /tmp

RUN # Update package list
RUN apt update

RUN # Install compile dependencies
RUN apt -y install git build-essential 
RUN apt -y install qt5-default qttools5-dev-tools libqt5svg5-dev libqt5serialport5-dev qtscript5-dev qtmultimedia5-dev libelf-dev 

RUN # Build source
ARG SIMULIDE_VERSION=0.3.11
#RUN wget "https://www.patreon.com/file?h=25271918&i=3426828" -O SimulIDE_${SIMULIDE_VERSION}.tgz
#RUN tar xzvf SimulIDE_${SIMULIDE_VERSION}.tgz
ADD https://api.github.com/repos/Sebastien-Posca/simulide-CLI/git/ref/heads/master version.json
RUN git clone https://github.com/Sebastien-Posca/simulide-CLI.git
WORKDIR /tmp/simulide-CLI/simulide-master/build_XX
RUN qmake
RUN make -j$(nproc)
RUN mkdir /simulide
RUN cp -ar /tmp/simulide-CLI/simulide-master/build_XX/release/SimulIDE_${SIMULIDE_VERSION} /simulide


###
# Build the avr vm
FROM debian:stable-slim AS dockeravr-vm
LABEL maintainer="Stéphane Lavirotte <stephane@lavirotte.com>"
WORKDIR /opt

RUN # Update package lists
RUN apt update

RUN # Install runtime dependencies
RUN apt -y install libelf1 libqt5svg5 libqt5widgets5 libqt5multimedia5 libqt5gui5 libqt5xml5 libqt5script5 libqt5serialport5 libqt5concurrent5 libqt5core5a

# Pull SimulIDE source
#RUN apt -y install wget
#RUN wget "https://www.patreon.com/file?h=29670926&i=4387728" -O SimulIDE_0.3.12-SR3-Lin64.tar.gz
#RUN tar xzvf SimulIDE_0.3.12-SR3-Lin64.tar.gz
#RUN mv SimulIDE_0.3.12-SR3 simulide
#RUN rm -f SimulIDE_0.3.12-SR3-Lin64.tar.gz

COPY --from=simulide-builder /simulide /opt/simulide

ADD ./entrypoint.sh /opt/entrypoint.sh
ENTRYPOINT ["./entrypoint.sh"]

#RUN # Build source
# These seem to be the only deps actually required for a successful  build
#RUN apt-get -y install python build-essential libglib2.0-dev libpixman-1-dev
# These don't seem to be required but are specified here: https://wiki.qemu.org/Hosts/Linux
#RUN apt-get -y install libfdt-dev zlib1g-dev
# Not required or specified anywhere but supress build warnings
#RUN apt-get -y install flex bison
#RUN "qemu-${QEMU_VERSION}/configure" --static --target-list=arm-softmmu,aarch64-softmmu
#WORKDIR /simavr/simavr
#RUN make -j$(nproc)

#RUN # Strip the binary, this gives a substantial size reduction!
#RUN strip "arm-softmmu/qemu-system-arm" "aarch64-softmmu/qemu-system-aarch64"

# Build stage for fatcat
#FROM debian:stable-slim AS fatcat-builder
#ARG FATCAT_VERSION=v1.1.0
#ARG FATCAT_CHECKSUM="303efe2aa73cbfe6fbc5d8af346d0f2c70b3f996fc891e8859213a58b95ad88c"
#ENV FATCAT_TARBALL="${FATCAT_VERSION}.tar.gz"
#WORKDIR /fatcat

#RUN # Update package lists
#RUN apt-get update

#RUN # Pull source
#RUN apt-get -y install wget
#RUN wget "https://github.com/Gregwar/fatcat/archive/${FATCAT_TARBALL}"
#RUN echo "${FATCAT_CHECKSUM} ${FATCAT_TARBALL}" | sha256sum --check

#RUN # Extract source tarball
#RUN tar xvf "${FATCAT_TARBALL}"

#RUN # Build source
#RUN apt-get -y install build-essential cmake
#RUN cmake fatcat-* -DCMAKE_CXX_FLAGS='-static'
#RUN make -j$(nproc)


# Build the dockerpi VM image
#FROM busybox:1.31 AS dockeravr-vm
#LABEL maintainer="Stéphane Lavirotte <stephane@lavirotte.com>"
#ARG RPI_KERNEL_URL="https://github.com/dhruvvyas90/qemu-rpi-kernel/archive/afe411f2c9b04730bcc6b2168cdc9adca224227c.zip"
#ARG RPI_KERNEL_CHECKSUM="295a22f1cd49ab51b9e7192103ee7c917624b063cc5ca2e11434164638aad5f4"

#COPY --from=qemu-builder /qemu/arm-softmmu/qemu-system-arm /usr/local/bin/qemu-system-arm
#COPY --from=qemu-builder /qemu/aarch64-softmmu/qemu-system-aarch64 /usr/local/bin/qemu-system-aarch64
#COPY --from=fatcat-builder /fatcat/fatcat /usr/local/bin/fatcat

#ADD $RPI_KERNEL_URL /tmp/qemu-rpi-kernel.zip

#RUN cd /tmp && \
#    echo "$RPI_KERNEL_CHECKSUM  qemu-rpi-kernel.zip" | sha256sum -c && \
#    unzip qemu-rpi-kernel.zip && \
#    mkdir -p /root/qemu-rpi-kernel && \
#    cp qemu-rpi-kernel-*/kernel-qemu-4.19.50-buster /root/qemu-rpi-kernel/ && \
#    cp qemu-rpi-kernel-*/versatile-pb.dtb /root/qemu-rpi-kernel/ && \
#    rm -rf /tmp/*

#VOLUME /sdcard

#ADD ./entrypoint.sh /entrypoint.sh
#ENTRYPOINT ["./entrypoint.sh"]


# Build the dockerpi image
# It's just the VM image with a compressed Raspbian filesystem added
#FROM dockerpi-vm as dockerpi
#LABEL maintainer="Luke Childs <lukechilds123@gmail.com>"
#ARG FILESYSTEM_IMAGE_URL="http://downloads.raspberrypi.org/raspbian_lite/images/raspbian_lite-2019-09-30/2019-09-26-raspbian-buster-lite.zip"
#ARG FILESYSTEM_IMAGE_CHECKSUM="a50237c2f718bd8d806b96df5b9d2174ce8b789eda1f03434ed2213bbca6c6ff"

#ADD $FILESYSTEM_IMAGE_URL /filesystem.zip

#RUN echo "$FILESYSTEM_IMAGE_CHECKSUM  /filesystem.zip" | sha256sum -c
