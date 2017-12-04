# frozen_string_literal: true

describe user('test') do
  it { should exist }
end

describe directory('/opt/dw_test') do
  it { should exist }
  it { should be_owned_by 'test' }
end

describe file('/opt/dw_test/config.yml') do
  it { should exist }
  it { should be_owned_by 'test' }
end

describe service('dw_test') do
  it { should be_installed }
  it { should be_enabled }
  it { should be_running }
end

describe file('/opt/dw_test/config.yml') do
  it { should exist }
  its('content') { should match(/port: 8010/) }
  its('content') { should match(/user: test/) }
  its('content') { should match(/message: dw_test message/) }
end

describe command('curl -s http://localhost:8080') do
  its(:stdout) { should match(/dw_test message/) }
end
