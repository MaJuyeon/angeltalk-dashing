require 'net/http'
require 'json'
require 'httparty'
require 'digest/md5'


JENKINS_BASE_URL = '192.168.10.28' # specifiy the base url of your jenkins server here
JENKINS_PORT = 8080 # specify the port of the server here


current_valuation = 0
current_karma = 0
current_synergy = 0
jenkins_project = 'angeltalk-builds'

projects = [
  { user: 'admin', repo: 'angeltalk-builds', branch: 'master' }
]

def duration(time)
  secs  = time.to_int
  mins  = secs / 60
  hours = mins / 60
  days  = hours / 24

  if days > 0
    "#{days}d #{hours % 24}h ago"
  elsif hours > 0
    "#{hours}h #{mins % 60}m ago"
  elsif mins > 0
    "#{mins}m #{secs % 60}s ago"
  elsif secs >= 0
    "#{secs}s ago"
  end
end

def calculate_time(finished)
  finished ? duration(Time.now - Time.parse(finished)) : "--"
end

def translate_status_to_class(status)
  statuses = {
    'SUCCESS' => 'passed',
    'success' => 'passed',
      'fixed' => 'passed',
    'running' => 'pending',
     'failed' => 'failed',
     'succeeded' => 'passed'
  }
  statuses[status] || 'pending'
end


def build_data_jenkins(project, auth_token)
  api_url = 'http://admin:jeep8walrus@192.168.10.28:8080/job/angeltalk-builds/lastBuild/api/json'  
  api_response =  HTTParty.get(api_url, :headers => { "Accept" => "application/json" } )
  api_json = JSON.parse(api_response.body)  
  return {} if api_json.empty?

  latest_build = api_json

  build_id = "#{latest_build['fullDisplayName']}, build ##{latest_build['id']}"
  build_result = "#{latest_build['result']}"

  if build_result.nil?
    build_result = "running"
  else
    build_result = "#{latest_build['result']}"
  end

  data = {
    build_id: build_id,
    repo: "posclient",
    branch: "#{latest_build['fullDisplayName']}",
    time: "2013-02-12T21:33:30Z",
    state: "#{build_result.capitalize}",
    widget_class: "#{translate_status_to_class(build_result)}",
    #committer_name: latest_build['committer_name'],
    #commit_body: "\"#{latest_build['body']}\"",
  }
end


def build_data_j()
  api_url = 'http://admin:jeep8walrus@192.168.10.28:8080/job/angeltalk-builds/lastBuild/api/json'  
  api_response =  HTTParty.get(api_url, :headers => { "Accept" => "application/json" } )
  api_json = JSON.parse(api_response.body)  
  return {} if api_json.empty?

  latest_build = api_json
    
  build_id = "#{latest_build['fullDisplayName']}, build ##{latest_build['id']}"
  build_result = "#{latest_build['result']}"

  if build_result.nil?
    build_result = "running"
  else
    build_result = "#{latest_build['result']}"
  end

  data = {
    build_id: build_id,
    repo: "bitbucket blabla",
    branch: "#{latest_build['fullDisplayName']}",
    time: "#{Time.at(latest_build['timestamp'])}",
    state: "#{build_result.capitalize}",
    widget_class: "#{translate_status_to_class(build_result)}",
    #committer_name: latest_build['committer_name'],
    #commit_body: "\"#{latest_build['body']}\"",
  }
  return data
end



SCHEDULER.every '5s', :first_in => 0  do
  last_valuation = current_valuation
  last_karma     = current_karma
  current_valuation = 99
  current_karma     = 999999
  current_synergy = rand(100)
    
  data = build_data_j()

  send_event('welcome', data)
  send_event('valuation', { current: current_valuation, last: last_valuation })
  send_event('karma', { current: current_karma, last: last_karma })
  send_event('synergy',   { value: current_synergy })
    
=begin
  projects.each do |project|
    data_id = "circle-ci-#{project[:user]}-#{project[:repo]}-#{project[:branch]}"
    data = build_data_jenkins(project, '01708cf6d552432ff605fa88a8053dab0b76f1c9')
    send_event(data_id, data) unless data.empty?
  end
=end
end

