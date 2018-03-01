#!/usr/bin/env ruby
# Copyright (c) 2018 Solano Labs Inc.  All Rights Reserved

require 'fileutils'
require 'json'

FileUtils.mkdir_p(File.expand_path('~/.cf/'))
fname = File.expand_path('~/.cf/config.json')
fd = File.new(fname, File::CREAT|File::TRUNC|File::RDWR, 0644)

config_json = {
  "ConfigVersion" => 3,
  "Target" => "#{ENV['CF_API_SERVER']}",
  "APIVersion" => "2.75.0",
  "AuthorizationEndpoint" => "#{ENV['CF_AUTH_SERVER']}",
  "UaaEndpoint" => "#{ENV['CF_TOKEN_SERVER']}",
  "RoutingAPIEndpoint" => "",
  "AccessToken" => "#{ENV['CF_TOKEN_TYPE']} #{ENV['CF_ACCESS_TOKEN']}",
  "RefreshToken" => "#{ENV['CF_REFRESH_TOKEN']}"
}

JSON.dump(config_json, fd)
fd.close

# Now we can fetch org and space name
spaces = JSON.parse(`cf curl "/v2/spaces" -X GET -H "Content-Type: application/x-www-form-urlencoded" -d "q=organization_guid:#{ENV['CF_ORG_GUID']}"`)
orgs = JSON.parse(`cf curl "/v2/organizations" -X GET -H "Content-Type: application/x-www-form-urlencoded" -d "q=space_guid:#{ENV['CF_SPACE_GUID']}"`)

current_space = spaces["resources"].find { |space| space["metadata"]["guid"] == ENV['CF_SPACE_GUID'] }
current_org = orgs["resources"].find { |org| org["metadata"]["guid"] == ENV['CF_ORG_GUID'] }

fd = File.new(fname, File::CREAT|File::TRUNC|File::RDWR, 0644)

config_json.merge!({
  "OrganizationFields" => {
    "GUID" => "#{ENV['CF_ORG_GUID']}",
    "Name" => "#{current_org['entity']['name']}",
  },
  "SpaceFields" => {
    "GUID" => "#{ENV['CF_SPACE_GUID']}",
    "Name" => "#{current_space['entity']['name']}"
  }
})

JSON.dump(config_json, fd)
fd.close
