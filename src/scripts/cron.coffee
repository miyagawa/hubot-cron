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

registerNewJobFromBrain = (robot, id, pattern, user, message) ->
  # for jobs saved in v0.2.0..v0.2.2
  user = user.user if "user" of user
  registerNewJob(robot, id, pattern, user, message)

registerNewJob = (robot, id, pattern, user, message) ->
  JOBS[id] = new Job(id, pattern, user, message)
  JOBS[id].start(robot)
  JOBS[id]

module.exports = (robot) ->
  robot.brain.data.cronjob or= {}
  robot.brain.on 'loaded', =>
    for own id, job of robot.brain.data.cronjob
      registerNewJobFromBrain robot, id, job...

  robot.respond /(?:new|add) job "(.*?)" (.*)$/i, (msg) ->
    try
      id = createNewJob robot, msg.match[1], msg.message.user, msg.match[2]
      msg.send "Job #{id} created"
    catch error
      msg.send "Error caught parsing crontab pattern: #{error}. See http://crontab.org/ for the syntax"

  robot.respond /(?:list|ls) jobs?/i, (msg) ->
    for id, job of JOBS
      room = job.user.reply_to || job.user.room
      msg.send "#{id}: #{job.pattern} @#{room} \"#{job.message}\""

  robot.respond /(?:rm|remove|del|delete) job (\d+)/i, (msg) ->
    id = msg.match[1]
    if JOBS[id]
      JOBS[id].stop()
      delete robot.brain.data.cronjob[id]
      delete JOBS[id]
      msg.send "Job #{id} deleted"
    else
      msg.send "Job #{id} does not exist"

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

