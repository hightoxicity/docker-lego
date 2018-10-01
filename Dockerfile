FROM golang:1.11.0-alpine3.8 as builder-lego
ENV COMMIT_HASH_LEGO ad20bf90ff5479cb8c63aef7e0f773b3c7e35835
ENV GOPATH /go
RUN apk add git
RUN go get -u github.com/xenolf/lego
WORKDIR ${GOPATH}/src/github.com/xenolf/lego
RUN git checkout ${COMMIT_HASH_LEGO}
RUN CGO_ENABLED=0 GOOS=linux go build -a -ldflags '-X main.GitSHA=${COMMIT_HASH_LEGO} -w -s -v -extldflags "-static"'

FROM golang:1.11.0-alpine3.8 as builder-confd
ENV COMMIT_HASH_CONFD cccd334562329858feac719ad94b75aa87968a99
ENV GOPATH /go
RUN apk add git
RUN go get -u github.com/kelseyhightower/confd
WORKDIR ${GOPATH}/src/github.com/kelseyhightower/confd
RUN git checkout ${COMMIT_HASH_CONFD}
RUN CGO_ENABLED=0 GOOS=linux go build -a -ldflags '-X main.GitSHA=${COMMIT_HASH_CONFD} -w -s -v -extldflags "-static"'

FROM alpine:3.8
ENV CONFIG_PATH /config.yml
COPY config.yml /config.yml
COPY entrypoint.sh /entrypoint.sh
COPY confd /confd
COPY --from=builder-lego /go/src/github.com/xenolf/lego/lego /bin/lego
COPY --from=builder-confd /go/src/github.com/kelseyhightower/confd/confd /bin/confd
RUN apk add ca-certificates
RUN update-ca-certificates
RUN rm -rf /var/cache/apk/*
RUN chmod 0755 /bin/lego
RUN chmod 0755 /bin/confd
ENTRYPOINT [ "/entrypoint.sh" ]
