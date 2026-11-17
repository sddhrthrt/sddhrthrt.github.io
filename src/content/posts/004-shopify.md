---
title: 'Fun at Shopify'
pubDate: '2020-04-01'
---

At Shopify, I was dropped in to debug, improve and maintain large PySpark pipelines orchestrated by Airflow. [Where had I seen that before?!](/001-adobe) But this time, data quantity was tremendous, rigor for correctness was more mature, and I was on the hook for oncall support, latency issues, and OOM errors with barely any hints of what went wrong.

As I got more used to what was going on, I found clever ways of solving problems. I wrote Splunk queries that would trawl through past weeks to identify pipelines that were frequently problematic: if you can't point at why something is happening, observe _when_ it is happening. Maybe that's a clue. I learned to load production data into notebooks and fillet the spark stages apart to glean something, anything, about the data that was causing the straggler spark stages. I hopped on pagerduty alarms at 2am, only to sniff a dud and type "should be fine in the next run" in incident response channel.

In the coming year, I moved towards the real-time analytics stack. Written in golang, deployed on kubernetes clusters deployed on Google Cloud, powered by BigTable, cloud storage objects, queries against live MySQL instances, orchestrated by kafka queues that plumbed everytihng together - I was exhilerated, overwhelmed, challenged, and engaged. I held my patience as I put together a picture of the tech stack complete with weaknesses and bottlenecks - you can't change things too easily or too quickly in a large organization with mature software.

Come 2022, we knew an aging stack needed replacing. However, the problem was hard. I'll try to explain why, without incurring the wrath of my Zionist ex-employer: 


There are a few peculiarities that make it hard to build a solution for this problem:

- The Analytical Data Store will need the ability to recieve updates to any part of the data. There is no "settled" part and a "volatile" part: all data is volatile. Any optimized roll-ups, caches, joined views will all need to accommodate updates.
- Query response SLA is a second or less. The product doesn't have "be back in a few minutes and we'll have the results ready" async mode. A quick "how much did I sell from this shop yesterday" and "how did quantities of each variant change in our inventory during the last six months, filtered by discount code MH2025" both have what felt like identical SLA. Arguably this is a product problem, but if you try to convince the product, you're a whiny data engineer.
- To satisfy such requirements, you end up designing storage at multiple grains: daily, monthly grain summaries, sales and discount summaries for each discount code at monthly grain, and so on. The stack both infers (or we infer manually) the grains that can best serve frequent queries, but we also keep these summaries up-to-date with updates to the past.
- Finally, there's the need to join tables at query time. This is arguably the worst part of it all: these are not predetermined joins you can optimize for by indexing, broadcasting, caching. There is a large permutation set of tables that can be joined, on columns of varying nature (primary keys, text, nullable, multi-column) and results might need a range of processing (group by, windowing, having, sort). 

Rather than designing the storage for each part of the product, with its use case, you are designing the storage for an arbitrary range of queries that each customer decides is the right one for them. We moved from curating a few reports that we thought was a broad fit for most customers to "write your own query with this custom query language we built for you" - a massive promise.

