FROM debian:buster

RUN apt update && apt install -y locales-all

# RUN locale-gen en_US en_US.UTF-8 && \
#     update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 && \
#     export LANG=en_US.UTF-8

RUN apt update && apt install -y \
    curl \
    gnupg2 \
    lsb-release

RUN curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | apt-key add -
RUN sh -c 'echo "deb [arch=$(dpkg --print-architecture)] http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" > /etc/apt/sources.list.d/ros2-latest.list'

RUN apt update && apt install -y \
  build-essential \
  cmake \
  git \
  libbullet-dev \
  python3-colcon-common-extensions \
  python3-flake8 \
  python3-pip \
  python3-pytest-cov \
  python3-rosdep \
  python3-setuptools \
  python3-vcstool \
  wget
# install some pip packages needed for testing
RUN python3 -m pip install -U \
  argcomplete \
  flake8-blind-except \
  flake8-builtins \
  flake8-class-newline \
  flake8-comprehensions \
  flake8-deprecated \
  flake8-docstrings \
  flake8-import-order \
  flake8-quotes \
  pytest-repeat \
  pytest-rerunfailures \
  pytest
# install Fast-RTPS dependencies
RUN apt install --no-install-recommends -y \
  libasio-dev \
  libtinyxml2-dev
# install Cyclone DDS dependencies
RUN apt install --no-install-recommends -y \
  libcunit1-dev

RUN mkdir -p /ros2_foxy/src
WORKDIR /ros2_foxy
RUN wget https://raw.githubusercontent.com/ros2/ros2/foxy/ros2.repos && \
    vcs import src < ros2.repos

RUN rosdep init && \
    rosdep update && \
    rosdep install --from-paths src --ignore-src --rosdistro foxy -y --skip-keys "console_bridge fastcdr fastrtps rti-connext-dds-5.3.1 urdfdom_headers"

RUN colcon build --symlink-install