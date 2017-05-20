require "rubygems"
require "serverspec"
require "docker-api"

describe "Dockerfile" do
  before(:all) do
    image = Docker::Image.build_from_dir('.')

    set :os, family: :alpine
    set :backend, :docker
    set :docker_image, image.id
  end

  it "installs the right version of Alpine" do
    expect(os_version).to include("Alpine Linux 3.")
    expect(os[:family]).to be(:alpine)
  end

  it "installs required packages" do
    expect(package("openldap")).to be_installed
  end

  # describe port(389) do
  #   it { should be_listening.on('0.0.0.0').with('tcp') }
  # end

  describe process("/usr/sbin/slapd") do
    its(:user)  { should eq "ldap" }
    its(:group) { should eq "ldap" }
    its(:pid)   { should eq 1      }
  end

  private

  def os_version
    command("cat /etc/issue").stdout
  end


end