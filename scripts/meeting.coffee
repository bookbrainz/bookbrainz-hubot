moment = require 'moment'

module.exports = (robot) ->
  robot.respond /meeting\?/i, (res) ->
    now = moment.utc()
    meeting = moment().day(5).hour(21).minute(30)
    meeting = if meeting < now then meeting.add(7, 'days') else meeting

    res.reply "The next BookBrainz meeting will be " + meeting.fromNow() +
      " (" + meeting.calendar() + " UTC)!"
