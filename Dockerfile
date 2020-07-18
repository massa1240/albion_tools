FROM elixir:1.10-alpine

WORKDIR /app

COPY mix.exs /app/mix.exs

RUN apk --update add openssh-client git nodejs nodejs-npm inotify-tools &&\
	rm -rf /var/cache/apk/* &&\
	mix local.hex --force &&\
	mix archive.install --force hex phx_new 1.4.16 &&\
	mix local.rebar --force &&\
	mix deps.get

COPY . /app

WORKDIR /app
