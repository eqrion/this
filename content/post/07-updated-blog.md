+++
title = "Updated Blog"
date = "2018-12-26T21:52:02-06:00"
slug = "updated-blog"
aliases = [
  "/post/updated-blog/",
]
tags = ["web", "blog"]
description = ""
disqusid = "1153"
draft = false
+++

I’ve been intending to write some new content on my blog, so I thought I should also update the site while I’m at it.


### `Https`

The first and most important change is `https` support. I’ve been a bit lazy here, but I finally decided to just do it.

This site is hosted on AWS as a [static website](https://docs.aws.amazon.com/AmazonS3/latest/dev/WebsiteHosting.html). I followed this nice [guide](https://medium.com/@sbuckpesch/setup-aws-s3-static-website-hosting-using-ssl-acm-34d41d32e394) which describes how to use Cloudfront as a CDN for S3 to get `https` support.

<!--more-->

It feels like overkill to add a CDN just to get `https` support, but it’s the easiest method I’ve seen that also works with S3.

In the end, I pay about $0.90 a month to AWS for hosting this site (S3, CloudFront, Route53), so I think it's acceptable.

### New domain and permalinks

The next major change is the domain. I’ve moved the domain from `dreamingofbits.com` to `blog.eqrion.net`.

I’ve been using `eqrion.net` for most public things now, so I figured I should move my blog over. All old links should still continue to work.

I’ve also updated the [permalink structure](https://gohugo.io/content-management/urls/#permalinks) to make links to posts a lot better.

In summary, links changed from:

 * [`http://dreamingofbits.com/post/edgehtml-and-control-of-the-web-platform/`](http://dreamingofbits.com/post/edgehtml-and-control-of-the-web-platform/)

To:

 * [`https://blog.eqrion.net/edgehtml-and-control-of-the-web-platform/`](https://blog.eqrion.net/edgehtml-and-control-of-the-web-platform/)

### Styling

As I was reviewing the styling of my blog, I noticed that you couldn't easily tell who was the author. So I've changed the title of the blog to make this more obvious.

I’ve also touched up colors and font sizes to increase legibility. It’s a bit of an art, and I’m sure it can still be improved. I can only go so far as a programmer.

And finally, the CSS is now minified and some unused resources were cut out. Turns out, there were some old web fonts and scripts still being loaded!

The website should look a bit better, and load a lot faster.

### Licensing

The last change is to the licensing. I host all of the source and content of this blog on [Github](https://github.com/eqrion/dreamingofbits/), but previously I hadn't include a license for the content.

I’ve now licensed the content of this blog under the [Creative Commons Attribution 4.0 International](https://creativecommons.org/licenses/by-sa/4.0/) license. There should be a notice on each page.

### Future work

In the future, I'd like to take a hard look at the accessibility of this site. I have a feeling it’s okay because I try to stick to [Semantic HTML](https://en.wikipedia.org/wiki/Semantic_HTML). I just haven’t looked into it enough to be confident of that.

I’d also like to take a look at other options for analytics and comments besides Google and Disqus.

I’m aware of `Talk` for comments from [Mozilla](https://coralproject.net/), but that currently requires rolling your own hosting. Which I'd rather not do at this time.

If anyone has suggestions, please let me know. Thanks!

