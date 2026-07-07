+++
date = "2015-02-15T21:51:26-05:00"
title = "Reliable Networking with a Sliding Window Protocol"
slug = "reliable-networking"
aliases = [
  "reliable-networking-with-a-sliding-window-protocol/",
  "/post/reliable-networking-with-a-sliding-window-protocol/",
]
description = "I've always been interested in how networking protocols work, and how they can be reliable and also efficient. After some reading, I decided the best way to learn about it would be for me to have to write one. If you do research on this topic, you'll find guides that describe all the important ideas, such as ARQ's and sliding window protocols, and they do a good job at describing the general idea of what they accomplish and how. I wrote this to try and provide an end to end guide on how some reliable networking protocols operate. It goes into enough depth to cover most of the implementation details that arise, but code is not actually discussed. If you are looking for code, the c++ library created along with this article can be found here. Hopefully this will provide some help for anyone else seeking to do this in the future."
draft = false
tags = ["networking", "project"]
disqusid = "1092"
+++

I've always been interested in how networking protocols work, and how they can be reliable and also efficient. After some reading, I decided the best way to learn about it would be for me to have to write one.

It turned out to be much more difficult than I anticipated, and I only really 'got' the idea on my third try.

If you do research on this topic, you'll find guides that describe all the important ideas, such as [ARQ's](https://en.wikipedia.org/wiki/Automatic_repeat_request) and [sliding window protocols](https://en.wikipedia.org/wiki/Sliding_window_protocol), and they do a good job at describing the general idea of what they accomplish and how. But all the references I found used very opaque terminology and didn't go into enough detail to actually implement the protocols.

This was especially true for Sliding Window Protocols. I wrote this to try and provide an end to end guide on how some reliable networking protocols operate. It goes into enough depth to cover most of the implementation details that arise, but code is not actually discussed.

If you are looking for code, the c++ library created along with this article can be found [here](https://github.com/eqrion/netmod). Hopefully this will provide some help for anyone else seeking to do this in the future!

<!--more-->

Before we get into the details of the different ways to send data reliably, we need to talk about the different types of reliability and the current protocols out there. If this is familiar to you, feel free to skip ahead.

## Reliability

There are two main types of reliability that we're concerned with in networking protocols. The first is Delivery. Will the packets I send reach their destination eventually, even in spite of being dropped? The second is Order. Will the packets I send be processed by their destination in the same order I send them, even in spite of being dropped or re-routed?

Delivery, and Order can be applied independently of each other. It's possible to have a protocol with both, one or the either, or neither. For example, you could only process packets in order, while not guaranteeing that every packet will reach its destination. Or you could guarantee delivery, while not guaranteeing they will be processed in order. More commonly though, we see TCP and UDP offering two different extremes of reliability.


|     | Eventual Delivery | In Order|
|-----|:-----------------:|:-------:|
|*TCP*|Yes|Yes|
|*UDP*|No|No|

I think there are times where it makes sense to not guarantee the order of packets, but that they will be delivered. Often times it's important that some state is eventually received by a client, but it doesn't matter if other state is processed before it. It's just important that it gets there eventually. So I set out to write a protocol that supports two modes; guaranteed in order data, and just guaranteed data. And those are the two guarantees that I'll be talking about.

To do this, we'll need to talk about some theory.

## A Simple Reliable Protocol

The first protocol to start with is the Delayed Repeat Protocol. The main idea is to assign a sequence number to each packet sent. This is a number that only ever increases with time. The first packet is 0, the second one is 1, the third is 2, and so on. When a receiver reads a packet from the network, it can tell which packet it has received. At first it is expecting 0, then it expects 1, then 2, and so on. If the packet is out of order, it will discard it. The receiver sends an acknowledgment of which packet it wants next to the transmitter, whenever it receives a packet. The transmitter reads the acknowledgments it receives, and can track which packets need to be resent. After a short delay, if the transmitter has not received an acknowledgement for packets it has sent, it will resend the packets up to the last acknowledged, and wait for an acknowledgment again. Barring a network connection failure, this method will ensure guaranteed eventual in order delivery.

A sketch of this protocol's operation is here,

#### Transmitter Operation:

1. Send packets as they are available, attach a sequence number.
2. Receive acknowledgments, and track what the remote receiver has received.
3. After a short delay, if the remote receiver has not received all packets, then resend. Reset the delay.

#### Receiver Operation:

1. Receive packets as they come.
2. If the packet number is the next expected then process the packet.
3. If the packet number is not the next expected then discard.
4. Regardless, send an acknowledgment with the next packet number desired.

If this protocol is followed it guarantees that packets will be eventually received in order, and is the basis for all further extensions.

Unfortunately, this protocol has a major implementation issue. In this protocol, sequence numbers are unbounded. As this protocol is operated over long periods of time, the sequence numbers will need larger and larger numbers. On a computer this will eventually overflow, which will most likely cause the protocol to lock and fail. This can be solved with a modification.

## A Sliding Window Protocol

These problems can be solved by modifying the protocol slightly to something called a Sliding Window Protocol. The key idea is to limit the amount of packets that can be sent ahead of an acknowledgment. This is called the Window Size. So for a Window Size of W, the transmitter is limited to send up to W packets before it needs to wait for acknowledgments. It's called a Sliding Window Protocol because there is a 'window' of sequence numbers that are active at any time, and as the protocol makes progress, the window 'slides' along.

This modification is important because it will allow us to use sequence numbers mod X for some integer X. So if we choose an X such as 256, we can use an 8 bit unsigned integer and not be concerned with overflow. Overflow in this case is just Mod 256. In addition, the Sliding Window acts as a simple flow control and prevents network overload by bounding the number of packages sent. Although that is not the main motivation for this modification.

Now that we have the motivations and key ideas down, let's look at how it works. The terminology I use here is what makes the most sense to me, others use different terminology. These concepts will be extended to support receiving packets out of order, but for now we will just be concerned about reliable in order communication.

#### Transmitter Variables

1. Lowest Not Sent – abbreviated LnS, the lowest packet that hasn’t been transmitted yet. This is the number that the next new packet will be sent with. All packets below this number have been sent at least once, and may or may not have been received.
2. Lowest Not Acknowledged – abbreviated LnA, the lowest packet that hasn’t been acknowledged by the receiver. All packets below this number have been received. Packets above and at this number may or may not have been received, the transmitter doesn’t know.

#### Receiver Variables

1. Lowest Not Received – abbreviated LnR, the lowest packet that hasn’t been received. All packets below this number have been received. In an advanced receiver, some packets above this number may have been received and processed.
One key idea to remember is that the transmitter and receiver have no idea the exact values of each other's variables. That is why LnA and LnR are different variables. They technically track the same thing, just from different perspectives.

The final variable of the protocol is the Window Size, abbreviated W. The window size limits the number of packets a transmitter can send ahead of an acknowledgment. It can change dynamically but right now it is fixed.

These variables are closely related to each other by the following relation,

*LnA <= LnR <= LnS <= LnA + W*

We cannot have an acknowledgment higher than what the receiver has acknowledged, and the receiver cannot acknowledge a higher packet than what has been sent. This provides an ordering to the three variables. In addition, we cannot move LnS further than LnA + W. If we have, then we have sent too many packets, and violated the window size. These two properties are important to transmitting sequence numbers mod X.

Now that we have the variables and understand the relations between them, we can describe precisely how the protocol operates,

#### Transmitter Operation

1. Send packets as they are available to W ahead of LnA.
2. Receive acknowledgments and update LnA.
3. After a meaningful delay of no acknowledgments or progress, resend packets from LnA to below LnS

#### Receiver Operation

1. Receive packets as the come.
2. If the sequence number is LnR then accept it and move LnR forward, otherwise discard the packet.
3. Send an acknowledgment to the transmitter with the new LnR.

If those steps are followed then you have guaranteed in-order eventual delivery of packets. This modification, as it stands, does us no good if we aren't transmitting our sequence numbers mod X. The real goal is to transmit sequence numbers mod X, which will gives us a means to implement this algorithm.

## Transmitting Sequence Numbers mod X

The problem with a sequence number overflowing is that it will disrupt the fundamental relation of the tracking variables. The variables have to satisfy *LnA <= LnR <= LnS <= LnA + W*. But as LnS reaches the end of the range of an unsigned integer, it will overflow, and all of a sudden, LnS will be less than LnA. In fact LnS will be much less than LnA + W, so it will continue sending more than W packets, breaking the protocol. This happens, in some way, to each variable as it overflows.

So if we allow variables to overflow, we cannot rely on arithmetic ordering to give us difference, because when LnS wraps around, it becomes arithmetically less than LnA. But we still consider LnS to be logically greater than LnA. We need a way to unambiguously determine the logical difference between two sequence numbers. Once we have this we can determine whether incoming packets are valid or whether we can continue sending packets to the receiver, without worrying about overflow.

It turns out that if we just add three conditions to sequence numbers we can determine the logical difference. We need to,

1. Designate one sequence number as always being 'ahead' of the other sequence number. I call this the leading number, and the other number the trailing number. The leading number has been incremented at least as many times as the trailing number. In our system, this is given to us by the natural ordering of the sequence numbers *LnA <= LnR <= LnS <= LnA + W*.
2. Bound the distance the leading number can be from the trailing number. For us, this comes from the window size.
3. Bound the window size to be less than the amount of numbers we can use. So if we have 4 possible numbers on the range [0, 4), then we need to limit our window to be at most 3. This is because when have a window size of W, there are W + 1 possible states of the leading number. It can be anywhere from [0, W] ahead of the trailing number, which is W+1 possibilities. If we don't limit the window size, then we run into a situation where we have more possibilities than we have numbers. This creates the ambiguous situation where the leading number can wrap around all the way back to the trailing number, and we won't be able to determine if the leading number moved zero times or W times.

With these conditions in place, we can calculate the logical difference using this function,

```c
// leading number is ahead of trailing number
unsigned modDifference(unsigned leadingNumber, unsigned trailingNumber, unsigned highestPossibleNumber) {
  if (leadingNumber < trailingNumber) {
    // leading number wrapped around the end
    return (highestPossibleNumber + 1) - trailingNumber + leadingNumber;
  } else {
    // leading number has not wrapped around the end
    return leadingNumber - trailingNumber;
  }
}
```

Consider the following situations when we have 4 possible numbers and a window size of 3,

| A (Leading Number) | B (Trailing Number) | Difference of A, B |     |
| :----------------: | :-----------------: | :----------------: | :-- |
| 1 | 1 | 0 | A >= B, so no wrap around. We just do A - B = 0. |
| 2 | 1 | 1 | A >= B, so no wrap around. We just do A - B = 1. |
| 3 | 1 | 2 | A >= B, so no wrap around. We just do A - B = 2. |
| 0 | 1 | 3 | A < B, so A has wrapped around. We take (3 + 1) - B + A = 3. |

Now consider what happens if we violate the 3rd condition and have 4 numbers and a window size of 4,

| A (Leading Number) | B (Trailing Number) | Difference of A, B |     |
| :----------------: | :-----------------: | :----------------: | :-- |
|1 | 1 | ? | There are two possibilities. Either A has been incremented 4 times more than B, in which case it will wrap around back to the start. Or A has never been incremented. We can't tell the difference here.|

With this method in place we can determine the logical difference between any two sequence numbers. Using the logical difference we can then operate every part of the Sliding Window Protocol described above, and we no longer have to worry about out what happens when our integers overflow.

We now have all the pieces we need to implement an in order guaranteed delivery protocol (whew). To implement a protocol that allows packets to be dropped, we surprisingly need to add more logic.

## Receiving Packets Out of Order

Recall that in the original sliding window protocol, we have three variables, LnS, LnR, LnA. These three variables split the packets in three groups; packets that have been received, packets that have been sent but not acknowledged, and packets that have not been sent. Packets between LnA and LnS may or may not have been received. There isn’t enough information to tell.

If the transmitter knew exactly which packets have been received from LnA to LnS, then it wouldn’t waste time and bandwidth resending those packets. The receiver also needs this information so that it only processes packets once, and so that it can properly update LnR as each packet is received. In addition, the receiver can use this information to process packets as they come instead of waiting for them to come in order.

From my limited research, I did not stumble on a method to implement this. There may be a different way, I don't know. But the solution that I came up with is to use bit flags. Bit flags will only work if we have an integer with width that is greater than or equal to the window size. So if you are using a high window size, such as 128, this might not work.

The trick is to represent the ith bit as the delivery status of the i<sup>th</sup> packet, relative to LnA (on transmitters) or LnR (on receivers). So bit 0 will never be set because that would imply that the lowest not received had actually been received. If bit 1 is set, that means that the second packet sent was received. If all the bits are set besides bit 0, then that means that the full window has been received except for the first packet.

From the receiver’s point of view, this bit flag is called ‘messages received’ or MR. From the transmitter’s point of view, this bit flag is called ‘messages acknowledged’ or MA.

This protocol's operation is here,

#### Transmitter Operation

1. Send packets as they are available, never sending past W ahead of LnA.
2. Receive acknowledgments and update LnA and MA.
3. After a meaningful delay of no acknowledgments, resend packets not in MA from LnA to below LnS

### Receiver Operation

1. Receive packets as the come
2. If the sequence number is not set in MR, then process it and set the proper bit of MR. Right Shift MR until bit 0 is not set, incrementing LnR by 1 each time. Send an acknowledgement with LnR and MR.

The operation of the receiver has changed significantly and can be a little confusing. The receiver now accepts and processes any packet where the bit at the distance from its sequence number to LnR is not set. It then sets that bit. Now we have a problem. We may have just set the 0 bit, invalidating LnR. We right shift MR until the 0 bit is not set. Each time we shift, we increment the LnR by 1 because we are moving the window past a packet that has been processed.

The net result of these changes is that by sending a little more information in each acknowledgment and not caring what order packets are processed in, we can save a lot of bandwidth.

## Conclusion

With this final idea, we now have all the pieces to implement the different reliability levels. The implementation for each is summarized below,

#### Eventual Delivery ####

Use a Sliding Window Protocol on top of UDP and use a bitfield to track delivery statuses and accept and process packets as they come in.

#### Eventual Delivery & In Order ####

Use a Sliding Window Protocol on top of UDP and either,

1. Only accept packets in order.
2. Use a bitfield to track delivery statuses and hold on to packets in memory until all previous packets have been accepted and processed.

You can find the library I created in the process of writing this post [here](https://github.com/eqrion/netmod/).

Questions, comments, corrections? Leave a comment below!