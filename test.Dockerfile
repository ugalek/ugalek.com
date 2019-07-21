FROM swift:5.0.1-bionic
WORKDIR /package
COPY . ./
RUN apt-get -qq update && apt-get -q -y install zlib1g-dev openssl libssl-dev tzdata
RUN git clone https://github.com/vishnubob/wait-for-it.git
RUN swift package resolve
RUN swift package clean
CMD ["./wait-for-it/wait-for-it.sh", "db_test:5432", "--", "swift", "test"]
