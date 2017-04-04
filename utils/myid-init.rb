#!/usr/bin/env ruby

require 'mongo'

cl = Mongo::Client.new('mongodb://127.0.0.1/test')['myid']
(1000..9999).to_a.shuffle.each do |myid|
  cl.insert_one({myid: myid, in_use: 0})
end
