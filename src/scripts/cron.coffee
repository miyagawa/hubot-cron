# Description:
#   register cron jobs to schedule messages on the current channel
#
# Commands:
#   hubot new job "<crontab format>" <message> - Schedule a cron job to say something
#   hubot new job <crontab format> "<message>" - Same, different quoting
#   hubot list jobs - List current cron jobs
#   hubot remove job <id> - remove job
#   hubot remove job with message <message> - remove with message
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

registerNewJobFromBrain = (robot, id, pattern, user, message) ->
  # for jobs saved in v0.2.0..v0.2.2
  user = user.user if "user" of user
  registerNewJob(robot, id, pattern, user, message)

registerNewJob = (robot, id, pattern, user, message) ->
  job = new Job(id, pattern, user, message)
  job.start(robot)
  JOBS[id] = job

unregisterJob = (robot, id)->
  if JOBS[id]
    JOBS[id].stop()
    delete robot.brain.data.cronjob[id]
    delete JOBS[id]
    return yes
  no

handleNewJob = (robot, msg, pattern, message) ->
  try
    id = createNewJob robot, pattern, msg.message.user, message
    msg.send "Job #{id} created"
  catch error
    msg.send "Error caught parsing crontab pattern: #{error}. See http://crontab.org/ for the syntax"

module.exports = (robot) ->
  robot.brain.data.cronjob or= {}
  robot.brain.on 'loaded', =>
    for own id, job of robot.brain.data.cronjob
      registerNewJobFromBrain robot, id, job...

  robot.respond /(?:new|add) job "(.*?)" (.*)$/i, (msg) ->
    handleNewJob robot, msg, msg.match[1], msg.match[2]

  robot.respond /(?:new|add) job (.*) "(.*?)" *$/i, (msg) ->
    handleNewJob robot, msg, msg.match[1], msg.match[2]

  robot.respond /(?:list|ls) jobs?/i, (msg) ->
    for id, job of JOBS
      room = job.user.reply_to || job.user.room
      if room == msg.message.user.reply_to or room == msg.message.user.room
        msg.send "#{id}: #{job.pattern} @#{room} \"#{job.message}\""

  robot.respond /(?:rm|remove|del|delete) job (\d+)/i, (msg) ->
    if (id = msg.match[1]) and unregisterJob(robot, id)
      msg.send "Job #{id} deleted"
    else
      msg.send "Job #{id} does not exist"

  robot.respond /(?:rm|remove|del|delete) job with message (.+)/i, (msg) ->
    message = msg.match[1]
    for id, job of JOBS
      room = job.user.reply_to || job.user.room
      if (room == msg.message.user.reply_to or room == msg.message.user.room) and job.message == message and unregisterJob(robot, id)
        msg.send "Job #{id} deleted"

class Job
  constructor: (id, pattern, user, message) ->
    @id = id
    @pattern = pattern
    # cloning user because adapter may touch it later
    clonedUser = {}
    clonedUser[k] = v for k,v of user
    @user = clonedUser
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
    envelope = user: @user
    robot.send envelope, @message

