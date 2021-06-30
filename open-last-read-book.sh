#!/bin/bash
last_opened_file=$(head .local/last-read-book)
zathura "$last_opened_file" &
