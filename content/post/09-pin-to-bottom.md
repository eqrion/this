+++
title = "Implementing a pin-to-bottom scrolling element with only CSS"
date = "2019-03-28T5:08:02-06:00"
slug = "pin-to-bottom"
aliases = [
  "/post/pin-to-bottom/",
]
tags = ["web", "scroll-anchoring"]
description = ""
disqusid = "1155"
draft = false
+++

Have you ever tried implementing a scrollable element where new content is being added and you want to pin the user to the bottom? It's not trival to do correctly.

I recently worked on a new CSS feature called 'scroll anchoring' that shipped in [Firefox 66](https://www.mozilla.org/en-US/firefox/66.0/releasenotes/) (for an introduction, check out my post on [Mozilla Hacks](https://hacks.mozilla.org/2019/03/scroll-anchoring-in-firefox-66/) or the summary on [MDN](https://developer.mozilla.org/en-US/docs/Web/CSS/overflow-anchor/Guide_to_scroll_anchoring)).

While implementing this feature, [Nicolas Chevobbe](https://twitter.com/nicolaschevobbe) and I were debugging an issue and discovered that scroll anchoring can be used to create a pin-to-bottom scrolling element without any Javascript.

It's a neat trick, so I thought I'd post the snippet here and explain how it works.

<!--more-->

<link href="/css/prism.css" rel="stylesheet" />
<script src="/js/prism.js"></script>

### Demo

Below is a sample page that continuously adds content to a scrollable element. When the element overflows, scroll to the bottom to activate pin-to-bottom.

You'll need at least Firefox 66 or Chrome 51 for this to work.

<script async src="//jsfiddle.net/eqrion/Lte142dv/14/embed/result,html,css,js">
</script>

### How it works

The important snippets are as follows:

```html
<div id="scroller">
    <!-- append content here -->
    <div id="anchor"></div>
</div>
```

```css
#scroller * {
    /* don't allow the children of the scrollable element to be selected as an anchor node */
    overflow-anchor: none;
}

#anchor {
    /* allow the final child to be selected as an anchor node */
    overflow-anchor: auto;

    /* anchor nodes are required to have non-zero area */
    height: 1px;
}
```

This trick works by forcing `#anchor` to always be the anchor node. This causes the browser to perform scrolling to keep it in the same relative position as it's moved by new elements being inserted.

Because `#anchor` is at the bottom of the scrollable element this means keeping you scrolled to the bottom of the page.

All without using any Javascript.

### Conclusion

There's one flaw with this approach.

Because browsers only activate scroll anchoring when you've scrolled away from the top of an element, a user has to scroll before the pin-to-bottom feature will kick in.

I've found this okay for my purposes, but if you want it to kick in immediately you should be able to do it with some additional Javascript to trigger a `1px` scroll.

Let me know if you found this interesting or found any other non-obvious use cases for scroll anchoring!

