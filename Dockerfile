FROM elixir:1.15

WORKDIR /app

ENV MIX_ENV="prod"

COPY mix.exs mix.lock /app/

RUN mix deps.get --only $MIX_ENV

RUN mix deps.compile

COPY lib /app/lib/

RUN mix compile

RUN mix release

CMD _build/prod/rel/autovoid/bin/autovoid start