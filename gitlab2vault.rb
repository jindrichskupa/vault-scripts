#!/usr/bin/env ruby

require 'gitlab'
require 'optparse'
require 'vault'
require 'json'

options = {}

optparse = OptionParser.new do |opts|
  opts.banner = "Usage: gitlab2vault.rb [options]"

  opts.on('-p', '--project PROJECTID', 'Gitlab project') do |v|
    options[:project] = v
  end

  opts.on('-r', '--group GROUPID', 'Gitlab group') do |v|
    options[:group] = v
  end

  opts.on('-x', '--old-prefix OLDPREFIX', 'Old prefix') do |v|
    options[:old_prefix] = v
  end

  opts.on('-y', '--new-prefix NEWPREFIX', 'New prefix') do |v|
    options[:new_prefix] = v
  end

  opts.on('-k', '--key-value KEYVALUEPATH', 'Vault secret path') do |v|
    options[:kv] = v
  end

  opts.on('-g', '--gitlab GITLABURL', 'Gitlab API URL') do |v|
    options[:gitlab] = v
  end

  opts.on('-q', '--gitlab-token GITLABTOKEN', 'Gitlab token') do |v|
    options[:gitlab_token] = v
  end

  opts.on('-v', '--vault VAULTURL', 'Vault URL') do |v|
    options[:vault] = v
  end

  opts.on('-u', '--vault-token VAULTTOKEN', 'Vault token') do |v|
    options[:vault_token] = v
  end
end

optparse.parse!

if options[:project].nil? && options[:group].nil?
  puts "Missing group or project"
  abort(optparse.help)
elsif options[:gitlab].nil? || 
  options[:gitlab_token].nil? || 
  options[:vault].nil? || 
  options[:vault_token].nil? ||
  options[:kv].nil?
  puts "Missing one of required options"
  abort(optparse.help)
end

Gitlab.configure do |config|
  config.endpoint       = options[:gitlab] || ENV['GITLAB_ADDR']
  config.private_token  = options[:gitlab_token] || ENV['GITLAB_TOKEN']
end

Vault.configure do |config|
  config.address = options[:vault] || ENV["VAULT_ADDR"]
  config.token   = options[:vault_token] || ENV["VAULT_TOKEN"]
end

if options[:project]
  vars = Gitlab.variables(options[:project])
elsif options[:group]
  vars = Gitlab.group_variables(options[:group])
end

vault_keys = {}

vars.auto_paginate do |var|
  vault_keys[var.key.gsub(options[:old_prefix],options[:new_prefix])] = var.value if var.key.start_with?(options[:old_prefix])
end

vault_keys.each do |k,v|
  puts "#{k} -> #{v}"
end

Vault.logical.write(options[:kv], data: vault_keys)
