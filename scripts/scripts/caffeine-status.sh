#!/bin/sh

if [ -f /tmp/caffeine ]; then
  echo '{"text":"󰅶 ON","tooltip":"Caffeine ON — click to disable","class":"active"}'
else
  echo '{"text":"󰾪 OFF","tooltip":"Caffeine OFF — click to enable","class":"inactive"}'
fi
