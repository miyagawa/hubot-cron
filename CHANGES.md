v0.2.6
======
* `list jobs` will send the list in one text to avoid firing notifications on some adapters

v0.2.5
======
* Remove robot.parseHelp from index (ngs) #13
* Add new command "remove job with message <message>" (ngs) #14
* Add new syntax "new job <crontab> say <message>"
* Fix errors with Slack adapter (deeeki) #15

v0.2.4
======
* Accept `hubot new job * * * * * "message here"` as well (different quotes)
* Only list jobs matching the current room
* Fix some error handling

v0.2.3
======
* Fix a bug introduced in 0.2.0 where envelope user is not restored properly from brain storage #8, #9

v0.2.2
======
* Fix backward compatibility for jobs created in older version of this plugin #8 (TakatoshiMaeda)

v0.2.1
======
* Fix a bug where reply_to is modified by adapters #6, #7 (@sorah)

v0.2.0
======
* Support external-scripts #1 (@francois2metz)
* Make sure ID generation doesn't conflict #2 (@gkoo)
* Support message envelopes for hubot v2.4.2+ #3 (@bergren2)
* Preload brain data before brain is loaded #4 (@jincod)

v0.1.0
======
* Intial release
