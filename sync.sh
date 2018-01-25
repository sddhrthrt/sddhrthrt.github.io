#!/bin/bash

JEKYLL_ENV=cs.toronto jekyll build --config=_config.yml,_config_prod.yml
rsync -avzP --delete -e ssh _site/ thota@cs.toronto.edu:public_html/
