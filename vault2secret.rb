#!/usr/bin/env ruby

require 'optparse'
require 'vault'
require 'yaml'
require 'base64'

options = {}

optparse = OptionParser.new do |opts|
  opts.banner = "Usage: vault2secret.rb [options]"

  opts.on('-k', '--key-value KEYVALUEPATH', 'Vault secret path') do |v|
    options[:kv] = v
  end

  opts.on('-f', '--file FILE', 'Ouput file') do |v|
    options[:file] = v
  end

  opts.on('-v', '--vault VAULTURL', 'Vault URL') do |v|
    options[:vault] = v
  end

  opts.on('-u', '--vault-token VAULTTOKEN', 'Vault token') do |v|
    options[:vault_token] = v
  end

  opts.on('-n', '--name NAME', 'Secret name') do |v|
    options[:name] = v
  end

  opts.on('-m', '--namespace NAMESPACE', 'Secret namespace') do |v|
    options[:namespace] = v
  end

  opts.on('-b', '--base64', 'Vault values are Base64 encoded') do |v|
    options[:base64] = true
  end
end

optparse.parse!

if options[:vault].nil? || 
  options[:vault_token].nil? ||
  options[:kv].nil? ||
  options[:namespace].nil? ||
  options[:name].nil?
  puts "Missing one of required options"
  abort(optparse.help)
end

Vault.configure do |config|
  config.address = options[:vault] || ENV["VAULT_ADDR"]
  config.token   = options[:vault_token] || ENV["VAULT_TOKEN"]
end

vault_keys = Vault.logical.read(options[:kv])

output = {
  'apiVersion' => 'v1',
  'kind' => 'Secret',
  'type' => 'Opaque',
  'metadata' => {
    'name' => options[:name],
    'namespace' => options[:namespace]
  },
  'data' => {}
}
vault_keys.data[:data].each do |k,v|
  output['data'][k.to_s]= (options[:base64] ? v : Base64.strict_encode64(v))
end

if options[:file].nil?
  puts output.to_yaml
else
  File.write(options[:file], output.to_yaml)
end

