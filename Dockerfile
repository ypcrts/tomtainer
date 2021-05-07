# vi: ft=dockerfile tw=0 ts=2 sw=2 sts=2 fdm=marker fmr={{{,}}} et:
FROM public.ecr.aws/ubuntu/ubuntu:latest
ENV DEBIAN_FRONTEND="noninteractive" TZ="UTC"
RUN apt-get update && apt-get install -y git python3 python3-pip sudo virtualenvwrapper
RUN useradd -m user && usermod -a -G sudo user && ( echo 'user:password' | chpasswd ) 
USER root 
RUN apt-get install -y gettext libtool libtool-bin autoconf automake cmake g++ pkg-config unzip build-essential
RUN cd /tmp && git clone --depth 1 https://github.com/neovim/neovim  \
 && cd neovim &&  make CMAKE_BUILD_TYPE=RELEASE install

USER user
RUN mkdir ~/Projects && cd ~/Projects \
  && git clone --depth 1 https://github.com/ypcrts/lazybox.git \
  && cd lazybox && ./dots.sh \
  && sed -i -e '/ssh\.gitconfig/ s/^/;/' ~/.gitconfig \
  && cd builds && ./nvm.sh \
  && bash -c ". ~/.nvm/nvm.sh  && nvm install node"
RUN bash -c ". ~/.config/bash/interactive.sh && loadenv py && mkvirtualenv -p python3 3 && pip install -U pip \
  && pip install -U neovim"
RUN nvim +PlugInstall +qall

ENTRYPOINT /bin/bash -o vi
