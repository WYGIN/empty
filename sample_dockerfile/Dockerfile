FROM ubuntu:latest
RUN apt-get update && apt-get install -y git
RUN git clone https://github.com/paketo-buildpacks/samples.git
WORKDIR /
# ./samples/nodejs/react-yarn/*
COPY ./* /workspace/*

# RUN apt-get install -y curl
# RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
# RUN echo "deb https://dl.yarnpkg.com/debian stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
# RUN sudo apt update
# RUN sudo apt install yarn

# RUN yarn install
# ENTRYPOINT ["yarn"]
# CMD ["start"]