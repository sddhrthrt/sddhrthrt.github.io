#!/bin/bash

JEKYLL_ENV=cs.toronto jekyll build
rsync -avzP --delete -e ssh _site/ thota@cs.toronto.edu:public_html/
