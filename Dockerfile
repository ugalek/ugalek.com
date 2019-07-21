FROM swift:5.0.1-bionic

ARG env
ENV ENVIRONMENT=$env

RUN apt-get -qq update && apt-get -q -y install zlib1g-dev openssl libssl-dev tzdata

WORKDIR /app
COPY . .

RUN mkdir -p /build/lib && \
    cp -R /usr/lib/swift/linux/*.so /build/lib && \
    swift build -c release && mv `swift build -c release --show-bin-path` /build/bin

EXPOSE 8080
CMD /build/bin/Run serve --env $ENVIRONMENT --hostname 0.0.0.0 --port 8080
