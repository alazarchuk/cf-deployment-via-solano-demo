#!/usr/bin/env ruby
# Copyright (c) 2018 Solano Labs Inc.  All Rights Reserved

require 'json'

fname = File.expand_path('~/.cf/config.json')
fd = File.new(fname, File::CREAT|File::TRUNC|File::RDWR, 0644)

spaces = JSON.parse(`cf curl "/v2/spaces" -X GET -H "Content-Type: application/x-www-form-urlencoded" -d "q=organization_guid:#{ENV['CF_ORG_GUID']}"`)
orgs = JSON.parse(`cf curl "/v2/organizations" -X GET -H "Content-Type: application/x-www-form-urlencoded" -d "q=space_guid:#{ENV['CF_SPACE_GUID']}"`)

current_space = spaces["resources"].find { |space| space["metadata"]["guid"] == ENV['CF_SPACE_GUID'] }
current_org = orgs["resources"].find { |org| org["metadata"]["guid"] == ENV['CF_ORG_GUID'] }

config_json = {
  "ConfigVersion" => 3,
  "Target" => "https://api.system.aws-usw02-pr.ice.predix.io",
  "APIVersion" => "2.75.0",
  "AuthorizationEndpoint" => "https://login.system.aws-usw02-pr.ice.predix.io",
  "UaaEndpoint" => "https://uaa.system.aws-usw02-pr.ice.predix.io",
  "RoutingAPIEndpoint" => "",
  "AccessToken" => "#{ENV['CF_TOKEN_TYPE']} #{ENV['CF_ACCESS_TOKEN']}",
  "RefreshToken" => "#{ENV['CF_REFRESH_TOKEN']}",
  "OrganizationFields" => {
    "GUID" => "#{ENV['CF_ORG_GUID']}",
	"Name" => "#{current_org['entity']['name']}",
  },
  "SpaceFields" => {
    "GUID" => "#{ENV['CF_SPACE_GUID']}",
	"Name" => "#{current_space['entity']['name']}"
  }
}

JSON.dump(config_json, fd)
fd.close
