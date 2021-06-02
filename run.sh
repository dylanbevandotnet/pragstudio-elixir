#!/usr/bin/env bash
pushd refuge > /dev/null
mix ecto.create
mix ecto.migrate
mix phx.server
popd > /dev/null