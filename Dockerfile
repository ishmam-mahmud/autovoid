FROM elixir:1.15

WORKDIR /app

ENV MIX_ENV="prod"

COPY mix.exs mix.lock /

RUN mix deps.get --only $MIX_ENV

RUN mix deps.compile

COPY lib /

RUN mix compile

COPY config/runtime.exs config/

RUN mix release

CMD _build/prod/rel/autovoid/bin/autovoid