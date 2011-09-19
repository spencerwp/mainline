# encoding: utf-8
#--
#   Copyright (C) 2011 Gitorious AS
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

require "test_helper"
class Gitorious::Authentication::ConfigurationTest < ActiveSupport::TestCase
  context "Configuration" do
    setup do
      @ldap = Gitorious::Authentication::LDAPAuthentication.new({
          "server" => "localhost",
          "base_dn" => "DC=gitorious,DC=org"})
    end

    should "require a server name" do
      assert_raises Gitorious::Authentication::ConfigurationError do
        ldap = Gitorious::Authentication::LDAPAuthentication.new({"base_dn" => "DC=gitorious.DC=org"})
      end
    end

    should "require a base DN" do
      assert_raises Gitorious::Authentication::ConfigurationError do
        ldap = Gitorious::Authentication::LDAPAuthentication.new({"server" => "localhost"})
      end      
    end
    
    should "use a default LDAP port" do
      assert_equal 389, @ldap.port
    end

    should "default to simple tls encryption" do
      assert_equal :simple_tls, @ldap.encryption
    end

    should "provide a default attribute mapping" do
      assert_equal({"displayname" => "fullname", "mail" => "email"}, @ldap.attribute_mapping)
    end

    should "use a Net::LDAP instance by default" do
      assert_equal Net::LDAP, @ldap.connection_type
    end

    should "provide a default DN template" do
      assert_equal "CN={},DC=gitorious,DC=org", @ldap.distinguished_name_template
    end
  end

  class StaticLDAPConnection
    def initialize(opts)
    end
    
    def auth(username, password)
      @allowed = username == "CN=moe,DC=gitorious,DC=org" && password == "secret"
    end

    def bind
      @allowed
    end

    def search(options)
      ["displayname" => ["Moe Szyslak"], "mail" => ["moe@gitorious.org"]]
    end
  end
  
  context "Authentication" do
    setup do
      @ldap = Gitorious::Authentication::LDAPAuthentication.new({
          "server" => "localhost",
          "base_dn" => "DC=gitorious,DC=org",
          "connection_type" => StaticLDAPConnection
        })
    end

    should "not accept invalid credentials" do
      assert !@ldap.valid_credentials?("moe","LetMe1n")
    end
    
    should "accept valid credentials" do
      assert @ldap.valid_credentials?("moe","secret")
    end

    should "return the actual user" do
      assert_equal(users(:moe), @ldap.authenticate("moe","secret"))
    end
  end

  context "Auto-registration" do
    setup do
      @ldap = Gitorious::Authentication::LDAPAuthentication.new({
          "server" => "localhost",
          "base_dn" => "DC=gitorious,DC=org",
          "connection_type" => StaticLDAPConnection})
      users(:moe).destroy
    end
    
    should "create a new user with attributes mapped from LDAP" do
      user = @ldap.authenticate("moe", "secret")
      assert_equal "moe@gitorious.org", user.email
      assert_equal "Moe Szyslak", user.fullname
      assert_equal "moe", user.login

      assert user.valid?
    end
  end  
end
