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

require 'fast_test_helper'
require 'sample_repo_helpers'
require 'gitorious/git/branch'

require 'rugged'

module Gitorious
  module Git
    class CommitTest < MiniTest::Spec
      include SampleRepoHelpers

      def commit(sha)
        Commit.new(repo.lookup(sha))
      end

      describe "#id" do
        let(:repo) { sample_rugged_repo }

        it "is equal to the sha hash" do
          commit("20ea396").id.must_equal "20ea396ef7b00bd0bb5589c8da4f3f4d157d4934"
        end
      end

      describe "#id_abbrev" do
        let(:repo) { sample_rugged_repo }

        it "is equal to the abbreviated sha hash of length 7" do
          commit("20ea396ef7b00bd0bb5589c8da4f3f4d157d4934").id_abbrev.must_equal "20ea396"
        end
      end

      describe "#short_message" do
        let(:repo) { sample_rugged_repo('with_long_commit_message') }

        it "is equal to the first line of the commit message" do
          commit("12ceb842544211b7c56eeb55f6b45827f349e140").short_message.must_equal "First line."
        end
      end

      describe "#changeset" do
        let(:repo) { sample_rugged_repo('with_rebases') }
        let(:original) { commit("82fd08ade6aa5662856b1a6a9b960af1c9f7226b") }
        let(:cherry_picked) { commit("1402946025f7dbd377a92d92199cf4a90305bdad") }
        let(:other) { commit("cf122c88efa59437f80df593af4e062be96debaa") }

        it "has the same changeset if commit diffs are equal" do
          original.changeset.must_equal(cherry_picked.changeset)
        end

        it "has different changeset if commits diffs are different" do
          original.changeset.wont_equal(other.changeset)
        end
      end
    end
  end
end

