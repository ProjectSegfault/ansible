#!/bin/sh
find /usr/share/nginx/html -type f -exec sed -i s/pipedapi.kavin.rocks/{% if server_prefix == 'eu' %}api.piped.projectsegfau.lt{%else%}pipedapi.{{server_prefix}}.projectsegfau.lt{%endif%}/g {} \; -exec sed -i s/hyperpipeapi.onrender.com/hyperpipebackend.{{ server_prefix }}.projectsegfau.lt/g {} \; && /docker-entrypoint.sh && nginx -g "daemon off;"
