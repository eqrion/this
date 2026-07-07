#!/usr/bin/env bash
hugo
aws s3 sync --delete public s3://dreamingofbits.com/
aws cloudfront create-invalidation --distribution-id E16X85N55SGRE5 --paths '/*'
