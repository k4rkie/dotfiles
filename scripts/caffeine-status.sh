#!/bin/sh

if [ -f /tmp/caffeine ]; then
  echo '{"text":"caf:on","tooltip":"Caffeine ON — click to disable","class":"active"}'
else
  echo '{"text":"caf:off","tooltip":"Caffeine OFF — click to enable","class":"inactive"}'
fi
