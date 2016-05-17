#!/bin/bash

ps aux | grep capi_ | awk '{print $2}' | xargs kill -9
ps aux | grep scalable | grep stratEngine | awk '{print $2}' | xargs kill -9
