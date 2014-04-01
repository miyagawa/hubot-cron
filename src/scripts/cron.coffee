# Description:
#   register cron jobs to schedule messages on the current channel
#
# Commands:
#   hubot new job "<crontab format>" <message> - Schedule a cron job to say something
#   hubot list jobs - List current cron jobs
#   hubot remove job <id> - remove job
#
# Author:
#   miyagawa

cronJob = require('cron').CronJob

JOBS = {}

createNewJob = (robot, pattern, user, message) ->
  id = Math.floor(Math.random() * 1000000) while !id? || JOBS[id]
  job = registerNewJob robot, id, pattern, user, message
  robot.brain.data.cronjob[id] = job.serialize()
  id

registerNewJob = (robot, id, pattern, user, message) ->
  JOBS[id] = new Job(id, pattern, user, message)
  JOBS[id].start(robot)
  JOBS[id]

module.exports = (robot) ->
  robot.brain.on 'loaded', =>
    robot.brain.data.cronjob or= {}
    for own id, job of robot.brain.data.cronjob
      registerNewJob robot, id, job[0], job[1], job[2]

  robot.respond /(?:new|add) job "(.*?)" (.*)$/i, (msg) ->
    try
      id = createNewJob robot, msg.match[1], msg.message.user, msg.match[2]
      msg.send "Job #{id} created"
    catch error
      msg.send "Error caught parsing crontab pattern: #{error}. See http://crontab.org/ for the syntax"

  robot.respond /(?:list|ls) jobs?/i, (msg) ->
    for own id, job of robot.brain.data.cronjob
      msg.send "#{id}: #{job[0]} @#{job[1].room} \"#{job[2]}\""

  robot.respond /(?:rm|remove|del|delete) job (\d+)/i, (msg) ->
    id = msg.match[1]
    if JOBS[id]
      JOBS[id].stop()
      delete robot.brain.data.cronjob[id]
      msg.send "Job #{id} deleted"
    else
      msg.send "Job #{id} does not exist"

class Job
  constructor: (id, pattern, user, message) ->
    @id = id
    @pattern = pattern
    @user = user
    @message = message

  start: (robot) ->
    @cronjob = new cronJob(@pattern, =>
      @sendMessage robot
    )
    @cronjob.start()

  stop: ->
    @cronjob.stop()

  serialize: ->
    [@pattern, @user, @message]

  sendMessage: (robot) ->
    robot.send @user, @message

