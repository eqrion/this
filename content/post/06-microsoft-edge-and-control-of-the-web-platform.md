+++
date = "2018-12-10T08:08:20-05:00"
title = "EdgeHTML and control of the web platform"
slug = "edgehtml"
aliases = [
  "edgehtml-and-control-of-the-web-platform/",
  "/post/edgehtml-and-control-of-the-web-platform/",
]
draft = false
tags = ["web", "chrome"]
description = ""
disqusid = "1152"
+++

There's been a lot of discussion this past week around Microsoft's decision to abandon EdgeHTML and its implication on the future of the Web.

If you've missed this news, take a look at this post by [Microsoft](https://blogs.windows.com/windowsexperience/2018/12/06/microsoft-edge-making-the-web-better-through-more-open-source-collaboration/) and this response by [Mozilla](https://blog.mozilla.org/blog/2018/12/06/goodbye-edge/).

<!--more-->

*[personal opinion disclaimer]*

## *'Monoculture'*

The essence of this news is that we're near the tipping point where Chromium, the web engine, will become so ubiquitous that other web engines won't matter.

Some people are concerned that this is going to enter us into a new age of [IE6](https://en.wikipedia.org/wiki/Internet_Explorer_6).

But is that really fair? Chromium is an open source project with multiple organizations contributing. Is it really likely development would stagnate?

Wouldn't it be a good thing to have just one browser to develop for, that everyone can focus on improving?

Personally, I'm not concerned about stagnation. Chromium has been and will continue to be developed at a breakneck pace.

The problem here is that a single organization will have nearly unchecked control over the web platform.

This is not specific to Google and has nothing to do with the employees at Google working on Chromium. This problem is inherent to any large project under control of a single organization.

Other people have said a [lot](https://robert.ocallahan.org/2014/08/choose-firefox-now-or-later-you-wont.html) of [good](https://twitter.com/annevk/status/1070259200381632513) about this, I just want to add a couple points.

## Would WebAssembly exist if we only had Chromium?

Designing new features for the web platform is hard and there's a well known history of mistakes. Less known is the history of mistakes averted by other engines saying 'no' when one engine had gone astray.

There's a recent example of this that I want to highlight: [PNaCl](https://en.wikipedia.org/wiki/Google_Native_Client) and [WebAssembly](https://webassembly.org/).

PNaCl was the original way to run portable native code in Chrome. It wasn't well integrated with the Web platform and would've been extremely difficult for other browsers to implement.

It was only once [other vendors](https://robert.ocallahan.org/2017/06/webassembly-mozilla-won.html) said 'no' and pursued other paths did everyone come to the table to design something that is non-proprietary and truly integrates with the Web.

What incentive would Google have to consider an alternative design if they were the only web-compatible engine?

Browser engineers and product managers don't always have the best perspective on what the web should be. With only one organization controlling the web platform, it's much more likely a narrow perspective will be taken.

This is why it's important to have multiple organizations with real influence on the web platform. Otherwise, missing perspectives and ideas will not have a voice and the evolution of the web will go down wrong paths.

## Who controls Chromium?

But is it really true that Chromium is controlled by Google? Aren't there multiple organizations contributing to Chromium and helping shape its future? With Microsoft joining in, won't that further distribute decision making control?

The problem is that while other organizations contribute to Chromium, engineering and control of decision making is completely dominated by Google. And that won't change in the foreseeable future.

All important design decisions have, and will, go through Google. You can suggest any features, complain as loud as you want, but if you don't fall into their internal plans, nothing will happen.

Microsoft will have very little power here unless they decide to fork the project and build a replacement team to compete with the Chromium team.

## *'Chromium Foundation'*

Now what if Google were to create a ['Chromium Foundation'](https://twitter.com/_richtr/status/1070275428437377024) to distribute decision making authority? After all, there are tons of other open source projects that have a single implementation and don't have issues.

The problem here is that Google has no incentive to give up actual control over Chromium. Google has invested a ridiculous amount of money, time, and engineering power in building a platform that they have control over. A platform that supports every other major product they rely on and is critical to their long term future.

I can't imagine them voluntarily giving up control over this in a meaningful way. We could see a 'Chromium Foundation', but Google will always have complete control over Chromium. It's just in their rational interest.

If you want a real world comparison, look at the [United States, the UN, and the security council](https://en.wikipedia.org/wiki/United_Nations_Security_Council_veto_power).

The only way to have actual influence on the evolution of the Web is to control the implementation of a web engine that is used by a sizeable amount of people.

There are no shortcuts, standards bodies don't have power here, and Google will always own final control over Chromium.

## Conclusion

For the health of the web, we need other browser engines. The web is too critical a resource to let any one organization have complete control over it, and it's time again for this to be fought for.

If any of this struck a chord with you, please consider [trying Firefox](https://www.mozilla.org/en-US/firefox/fights-for-you/) or [contributing](https://developer.mozilla.org/en-US/docs/Mozilla/Developer_guide/Introduction) to improve it.

I understand that Firefox is not always perfect, and Mozilla sometimes makes mistakes, but we need an open web and Firefox is our best chance here. Firefox has improved dramatically recently, and work continues on.

If you have reasons why Firefox isn't great for you, please help us understand why. Consider [filing a bug](https://bugzilla.mozilla.org/). We really do want to improve even if we don't have the resources to do everything. The road ahead isn't easy, but it's important.
