# syntax=docker/dockerfile:1

FROM golang:1.22

WORKDIR /src

COPY go.mod go.sum ./
RUN go mod download

COPY *.go ./
COPY ./static ./static
COPY ./templates ./templates

RUN ls
RUN CGO_ENABLED=0 go build .

FROM scratch
COPY --from=0 /src/bestellen /bestellen
CMD ["/bestellen"]