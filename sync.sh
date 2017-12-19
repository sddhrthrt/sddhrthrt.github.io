#!/bin/bash

rsync -avzP --delete -e ssh _site/ thota@cs.toronto.edu:public_html/
