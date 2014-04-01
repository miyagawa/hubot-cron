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

## Usage

```
miyagawa> hubot new job "0 9 * * 1-5" Good morning everyone!
hubot> Job 12345 created

miyagawa> hubot list jobs
hubot> (list of jobs)

miyagawa> hubot rm job 12345
hubot> Job 12345 removed
```

You can use any [node-cron](https://github.com/ncb000gt/node-cron) compatible crontab format to schedule messages. Registered message will be sent to the same channel where you created a job.

To persist the cron job in the hubot restart, you're recommended to use redis to persist Hubot brain.

## See Also

`reminder.coffee` in hubot-scripts.
