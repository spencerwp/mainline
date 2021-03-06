# encoding: utf-8
#--
#   Copyright (C) 2013 Gitorious AS
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU Affero General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU Affero General Public License for more details.
#
#   You should have received a copy of the GNU Affero General Public License
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.
#++

class Service::Sprintly < Service::Adapter
  label "Sprint.ly"

  attributes :email, :product_id, :api_key

  validates :email, :presence => true
  validates :product_id, :presence => true
  validates :api_key, :presence => true

  def name
    "Sprint.ly"
  end

  def id
    email
  end

  def notify(http_client, payload)
    http_client.post "https://sprint.ly/integration/github/#{product_id}/push/",
      :body => payload.to_json,
      :content_type => "application/json",
      :basic_auth => { :user => email, :password => api_key }
  end
end
