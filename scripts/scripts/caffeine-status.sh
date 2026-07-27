#!/bin/sh

if [ -f /tmp/caffeine ]; then
  echo '{"text":"󰅶","tooltip":"Caffeine ON — click to disable","class":"active"}'
else
  echo '{"text":"󰾪","tooltip":"Caffeine OFF — click to enable","class":"inactive"}'
fi
