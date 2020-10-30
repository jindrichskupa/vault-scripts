#!/usr/bin/env ruby

require 'optparse'
require 'vault'
require 'json'
require 'base64'

options = {}

optparse = OptionParser.new do |opts|
  opts.banner = "Usage: files2vault.rb [options]"

  opts.on('-k', '--key-value KEYVALUEPATH', 'Vault secret path') do |v|
    options[:kv] = v
  end

  opts.on('-v', '--vault VAULTURL', 'Vault URL') do |v|
    options[:vault] = v
  end

  opts.on('-u', '--vault-token VAULTTOKEN', 'Vault token') do |v|
    options[:vault_token] = v
  end

  opts.on('-d', '--directory DIR', 'Directory') do |v|
    options[:dir] = v
  end
end

optparse.parse!

if options[:vault].nil? || 
  options[:vault_token].nil? ||
  options[:kv].nil? ||
  options[:dir].nil?
  puts "Missing one of required options"
  abort(optparse.help)
end

Vault.configure do |config|
  config.address = options[:vault] || ENV["VAULT_ADDR"]
  config.token   = options[:vault_token] || ENV["VAULT_TOKEN"]
end

vault_keys = {}

Dir[options[:dir]+'/*'].select { |f| File.file?(f) }.each do |f|
  vault_keys[File.basename f] = Base64.strict_encode64(File.read f)
end

vault_keys.each do |k,v|
  puts "#{k} -> #{v[0..10]}"
end

Vault.logical.write(options[:kv], data: vault_keys)
