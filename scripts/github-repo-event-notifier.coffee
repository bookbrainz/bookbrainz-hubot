url           = require('url')
querystring   = require('querystring')
eventActions  = require('./event-actions/all')
eventTypesRaw = process.env['HUBOT_GITHUB_EVENT_NOTIFIER_TYPES']
eventTypes    = []

if eventTypesRaw?
  eventTypes = eventTypesRaw.split(',')
else
  console.warn("github-repo-event-notifier is not setup to receive any events (HUBOT_GITHUB_EVENT_NOTIFIER_TYPES is empty).")

module.exports = (robot) ->
  robot.router.post "/hubot/gh-repo-events", (req, res) ->
    query = querystring.parse(url.parse(req.url).query)

    data = req.body
    room = query.room || process.env["HUBOT_GITHUB_EVENT_NOTIFIER_ROOM"]
    eventType = req.headers["x-github-event"]
    console.log "Processing event type #{eventType}..."

    try
      if eventType in eventTypes
        announceRepoEvent data, eventType, (what) ->
          robot.messageRoom room, what
      else
        console.log "Ignoring #{eventType} event as it's not allowed."
    catch error
      robot.messageRoom room, "Whoa, I got an error: #{error}"
      console.log "github repo event notifier error: #{error}. Request: #{req.body}"

    res.end ""

announceRepoEvent = (data, eventType, cb) ->
  if eventActions[eventType]?
    eventActions[eventType](data, cb)
  else
    cb("Received a new #{eventType} event, just so you know.")
