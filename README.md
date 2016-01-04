# hubot-cron

hubot-cron adds a cronjob system to hubot to schedule messages on a specific date and time.

## Installation

Add `hubot-cron` to your package.json, run `npm install` and add hubot-cron to `external-scripts.json`.

Add hubot-cron to your `package.json` dependencies.

```
"dependencies": {
  "hubot-cron": ">= 0.1.0"
}
```

Add `hubot-cron` to `external-scripts.json`.

```
> cat external-scripts.json
> ["hubot-cron"]
```

If you want to specify timezones, you'll need to install the [time](https://github.com/TooTallNate/node-time) module or place an entry for it in your package.json file.

    npm install time

## Usage

```
miyagawa> hubot new job 0 9 * * 1-5 "Good morning everyone!"
hubot> Job 12345 created

miyagawa> hubot list jobs
hubot> (list of jobs)

miyagawa> hubot rm job 12345
hubot> Job 12345 removed

miyagawa> hubot tz job 12345 America/Los_Angeles
hubot> Job 12345 updated to use America/Los_Angeles
```

You can use any [node-cron](https://github.com/ncb000gt/node-cron) compatible crontab format to schedule messages. Registered message will be sent to the same channel where you created a job.

To persist the cron job in the hubot restart, you're recommended to use redis to persist Hubot brain.

Timezones are specified in [tzdata format](https://en.wikipedia.org/wiki/Tz_database#Examples).


### Scheduling Tasks
You can schedule Hubot to run hubot tasks / commands / plugins by using the `exec` function to `hubot-cron`

```
miyagawa> hubot new job 0 9 * * 1-5 exec hubot ping
hubot> Job 45678 created

...

hubot> PONG
```

This will send the string `hubot ping` to hubot at the specified time and will be processed by hubot.

## See Also

`reminder.coffee` in hubot-scripts.
