#!/usr/bin/env ruby

require 'optparse'
require 'vault'
require 'json'

options = {}

optparse = OptionParser.new do |opts|
  opts.banner = "Usage: vault2vault.rb [options]"

  opts.on('-k', '--key-value1 KEYVALUEPATH1', 'Source vault secret path') do |v|
    options[:kv1] = v
  end

  opts.on('-l', '--key-value2 KEYVALUEPATH2', 'Destination vault secret path') do |v|
    options[:kv2] = v
  end

  opts.on('-v', '--vault VAULTURL', 'Vault URL') do |v|
    options[:vault] = v
  end

  opts.on('-u', '--vault-token VAULTTOKEN', 'Vault token') do |v|
    options[:vault_token] = v
  end

end

optparse.parse!

if options[:vault].nil? || 
  options[:vault_token].nil? ||
  options[:kv].nil?
  puts "Missing one of required options"
  abort(optparse.help)
end

Vault.configure do |config|
  config.address = options[:vault] || ENV["VAULT_ADDR"]
  config.token   = options[:vault_token] || ENV["VAULT_TOKEN"]
end

vault_keys = Vault.logical.read(options[:kv1])
Vault.logical.write(options[:kv2], data: vault_keys[:data])
