require File.dirname(__FILE__) + '/../spec_helper'

describe ApplicationHelper do
  
  it "renders a message if an object is not ready?" do
    repos = repositories(:johans)
    build_notice_for(repos).should include("This repository is being created")
  end
  
  it "renders block if object is ready" do
    obj = mock("any given object")
    obj.stub!(:ready?).and_return(true)
    render_if_ready(obj) do
      "moo"
    end.should == "moo"
  end
  
  it "renders block if object is ready" do
    obj = mock("any given object")
    obj.stub!(:ready?).and_return(false)
    _erbout = "" # damn you RSpec!
    render_if_ready(obj) do
      "moo"
    end
    _erbout.should_not == "moo"
    _erbout.should match(/is being created/)
  end
  
  it "gives us the domain of a full url" do
    base_url("http://foo.com").should == "foo.com"
    base_url("http://www.foo.com").should == "www.foo.com"
    base_url("http://foo.bar.baz.com").should == "foo.bar.baz.com"
    base_url("http://foo.com/").should == "foo.com"
    base_url("http://foo.com/bar/baz").should == "foo.com"
  end
  
  it "generates a valid gravatar url" do
    email = "someone@myemail.com";
    url = gravatar_url_for(email)
    
    base_url(url).should == "www.gravatar.com"
    url.include?(Digest::MD5.hexdigest(email)).should == true
    url.include?("avatar.php?").should == true
  end
  
    
  it "should generate a commit graph url" do
    project = projects(:johans)
    FileUtils.mkpath(project.mainline_repository.full_repository_path)
    
    url = commit_graph_tag(project)
    
    (url =~ /\<img/).should == 0
    url.include?("google.com").should == true
    
    Gchart.should_receive(:line)
    commit_graph_tag(project)
  end
  
  it "should generate a url for commit graph by author" do
    project = projects(:johans)
    FileUtils.mkpath(project.mainline_repository.full_repository_path)
    
    url = commit_graph_by_author_tag(project)
    (url =~ /\<img/).should == 0
    url.include?("google.com").should == true
    
    Gchart.should_receive(:pie)
    commit_graph_by_author_tag(project)
  end
end
