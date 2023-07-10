########################################################
# Dockerfile for crab tutorial in Dagstuhl 07/10/2023
########################################################
# The recommended way to obtain the docker image is to download it from
# dockerhub:
# 
#    docker pull seahorn/crab_dagstuhl_23
#
# Alternatively, you can build the docker image by yourself (it will take long time)
#
#    docker build -t seahorn/crab_dagstuhl_23 -f crab.Dockerfile .
#
# To load the image, just type:
#
# docker run -v `pwd`:/host -it seahorn/crab_dagstuhl_23
########################################################

ARG BASE_IMAGE=jammy-llvm14
FROM seahorn/buildpack-deps-seahorn:$BASE_IMAGE

# Needed to run clang with -m32
RUN apt-get install -yqq libc6-dev-i386

### Download crab
RUN cd / && rm -rf /crab && \
    git clone -b dev https://github.com/seahorn/crab crab;

## Download/install crabber
RUN cd / && rm -rf /crabber && \
    git clone https://github.com/caballa/crabber crabber; \
    mkdir -p /crabber/build
WORKDIR /crabber/build
RUN cmake -GNinja \
          -DCMAKE_BUILD_TYPE=RelWithDebInfo \
          -DCMAKE_INSTALL_PREFIX=run \
          -DCMAKE_CXX_COMPILER=clang++-14 \
	  -DCRAB_ROOT=/crab \
          -DCRAB_USE_APRON=ON \
          -DCRAB_USE_LDD=ON \	  	  
          -DCMAKE_EXPORT_COMPILE_COMMANDS=1 \
          ../ && \
    cmake --build . --target ldd  && cmake .. && \
    cmake --build . --target apron  && cmake .. && \
    cmake --build . --target install
WORKDIR /
ENV PATH "/crabber/build/run/bin:$PATH"

## Download/install clam
RUN cd / && rm -rf /clam && \
    git clone -b dev14 https://github.com/seahorn/clam.git clam; \
    mkdir -p /clam/build
WORKDIR /clam/build
RUN cmake -GNinja \
          -DCMAKE_BUILD_TYPE=RelWithDebInfo \
          -DCMAKE_INSTALL_PREFIX=run \
          -DCMAKE_CXX_COMPILER=clang++-14 \
	  -DCMAKE_C_COMPILER=clang-14 \
	  -DCRAB_ROOT=/crab \
          -DCRAB_USE_APRON=ON \
          -DCRAB_USE_LDD=ON \	  	  
          -DCMAKE_EXPORT_COMPILE_COMMANDS=1 \
          ../ && \
    cmake --build . --target extra  && cmake .. && \
    cmake --build . --target ldd  && cmake .. && \
    cmake --build . --target apron  && cmake .. && \
    cmake --build . --target install

RUN ln -s /usr/bin/clang-14 /usr/bin/clang
RUN ln -s /usr/bin/llvm-dis-14 /usr/bin/llvm-dis
ENV PATH "/usr/bin:$PATH"
ENV PATH "/clam/build/run/bin:$PATH"

WORKDIR /

RUN cd / && rm -rf /crab-dagstuhl-tutorial && \
    git clone https://github.com/caballa/crab-dagstuhl-tutorial;

WORKDIR /crab-dagstuhl-tutorial
