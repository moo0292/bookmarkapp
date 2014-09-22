require 'sinatra'
require 'securerandom'
require 'json/ext'
require 'digest/md5'

Dir.mkdir "nodes" unless Dir.exist? "nodes"
Dir.mkdir "tree" unless Dir.exist? "tree"

set :bind, '0.0.0.0'
set :port, 9001
set :port, ARGV[0] if ARGV[0].to_i > 1

def guid()
  SecureRandom.hex 8
end

def parse_node(node)
  if node.is_a? String
    parsed = JSON.parse File.readlines("nodes/" + node).join
    parsed.store("guid", node)
  end

  if node.is_a? Array
    parsed = parse_node(node.shift)
    node.each {|n|
      parsed[:children] ||= []
      parsed[:children] << parse_node(n)
    }
  end

  return parsed
end

get '/' do
  erb :index
end

get '/test' do
  t = Time.now.to_i

  [t.to_s,t.to_s(16),t.to_s(16).to_i(16)].to_json
end

get '/nodes' do
  headers "content-type" => "application/json", "Access-Control-Allow-Origin" => "*"

  output = []
  trees  = Dir.entries("tree").sort
  latest = JSON.parse File.readlines("tree/" + trees.last).join

  latest.each do |node|
    output.push parse_node(node)
  end

  JSON.pretty_generate output
end

get '/nodes/new' do
  erb :node_new
end

# create a node under a parent
get '/nodes/:guid/new' do
  erb params[:guid]
end

# create a brand new node
post '/nodes/new' do
  data = request.params
  data['date'] = Time.new

  json = data.to_json
  hash = (Digest::MD5.new << json).to_s
  name = guid + "-" + hash

  file = File.new("nodes/" + name, "w")
  file.write(json)

  redirect '/nodes/new'
end

# todo: *modifying a node
