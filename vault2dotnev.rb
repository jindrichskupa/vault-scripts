#!/usr/bin/env ruby

require 'optparse'
require 'vault'
require 'json'

options = {}

optparse = OptionParser.new do |opts|
  opts.banner = "Usage: vault2dotenv.rb [options]"

  opts.on('-k', '--key-value KEYVALUEPATH', 'Vault secret path') do |v|
    options[:kv] = v
  end

  opts.on('-e', '--dot-env DOTFILE', '.env file') do |v|
    options[:dot_file] = v
  end

  opts.on('-v', '--vault VAULTURL', 'Vault URL') do |v|
    options[:vault] = v
  end

  opts.on('-u', '--vault-token VAULTTOKEN', 'Vault token') do |v|
    options[:vault_token] = v
  end

  opts.on('--export', 'Export style .nev') do |v|
    options[:export] = true
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

vault_keys = Vault.logical.read(options[:kv])

lines = []
vault_keys.data[:data].each do |k,v|
  lines << "#{ options[:export] ? 'export ' : '' }#{k}=\"#{v}\""
end

if options[:dot_file].nil?
 pust lines.join("\n")
else
  File.write(options[:dot_file], lines.join("\n"))
end

