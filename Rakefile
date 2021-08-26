require 'tempfile'

container_name = ENV['EDULDAP_CONTAINER_NAME'] || "eduldap"
snapshot_name = "#{container_name}:snapshot"

full_version = File.read("VERSION").to_s.strip
token = ENV["GITHUB_TOKEN"] || File.read("#{Dir.home}/.tokens/.gh_token").to_s.strip
user = ENV["GITHUB_USER"] || File.read("#{Dir.home}/.tokens/.gh_user").to_s.strip

task :default => :refresh

task :refresh => [:build, :test]

desc "Build the Docker image"
task :build do

  tmp_file = Tempfile.new("docker")
  git_hash = `git rev-parse --short HEAD`

  rebuild_or_not = ENV["EDULDAP_FORCE_REBUILD"] ? "--pull --force-rm" : ""

  sh [
       "docker build --iidfile #{tmp_file.path}",
       "--label 'version=#{full_version}'",
       "--label 'org.opencontainers.image.revision=#{git_hash}'",
       "--build-arg GITHUB_TOKEN=#{token}",
       "--build-arg GH_USER=#{user}",
       rebuild_or_not,
       "./"
     ].join(" ")

  image_id = File.read(tmp_file.path).to_s.strip

  sh "docker tag #{image_id} ghcr.io/digital-identity-labs/#{container_name}:#{full_version}"
  sh "docker tag #{image_id} ghcr.io/digital-identity-labs/#{container_name}:latest"
  sh "docker tag #{image_id} #{container_name}:#{full_version}"
  sh "docker tag #{image_id} #{container_name}:latest"
  sh "docker tag #{image_id} #{snapshot_name}"

end

desc "Rebuild the image"
task :rebuild => [:force_reset, :build]

desc "Build the image and test"
task :test => [:build] do
  begin
    sh "docker run --rm -d -p 389:389 #{snapshot_name}"
    container_id = `docker ps -q -l`
    sleep ENV['CI'] ? 20 : 10
    colour = ENV['CI'] ? "--no-color" : "--color"
    # sh "bundle exec inspec exec specs/ishigaki-internal/ #{colour} --chef-license accept -t docker://#{container_id} "
  ensure
    sh "docker stop #{container_id}" if container_id
  end
end

task :shell => [:build] do
  sh "docker run --rm -d -p 389:389 #{snapshot_name}"
  container_id = `docker ps -q -l`.chomp
  sh "docker exec -it #{container_id} /bin/sh"
end

desc "Build and publish a Docker image to Github and Dockerhub"
task publish: [:build] do
  
  sh "docker image push ghcr.io/digital-identity-labs/#{container_name}:#{full_version}"
  sh "docker image push ghcr.io/digital-identity-labs/#{container_name}:latest"
  sh "docker image push digitalidentity/#{container_name}:#{full_version}"
  sh "docker image push digitalidentity/#{container_name}:latest"
end

task :force_reset do
  ENV["EDULDAP_FORCE_REBUILD"] = "yes"
end

