require "em-synchrony/em-http"

class HomeController < ApplicationController
  def index
    EventMachine.synchrony do
      logger.debug Time.now
      multi = EventMachine::Synchrony::Multi.new
      multi.add :a, EventMachine::HttpRequest.new("http://api.twitter.com/1/statuses/public_timeline.json?trim_user=true").aget
      multi.add :b, EventMachine::HttpRequest.new("http://api.twitter.com/1/statuses/followers.json?user_id=12345").aget
      res = multi.perform

      logger.debug Time.now
      resp = res.responses[:callback][:a].response
      @public_timeline = JSON.parse(resp).collect{|r| r["text"]}
      
      resp = res.responses[:callback][:b].response
      @followers = JSON.parse(resp).collect{|r| {:name => r["name"], :screen_name => r["screen_name"]}}

      EventMachine.stop
    end
  end
end
