require_relative '../spec_helper'
require 'fluentd_server/model'
require 'ext/activerecord/acts_as_file'

class TestPost < Post
  unless Post.include?(ActiveRecord::ActsAsFile)
    include ActiveRecord::ActsAsFile
    def filename
      @filename ||= Tempfile.open(self.name) {|f| f.path }.tap {|name| File.unlink(name) }
    end
    acts_as_file :body => self.instance_method(:filename)
  end
end

describe 'ActiveRecord::ActsAsFile' do
  let(:subject) { TestPost.new(name: 'name') }
  after { TestPost.delete_all }
  after { File.unlink(subject.filename) if File.exist?(subject.filename) }

  context '#body=' do
    it { expect { subject.body = 'aaaa' }.not_to raise_error }
  end

  context '#body' do
    context 'get from instance variable' do
      before { subject.body = 'aaaa' }
      its(:body) { should == 'aaaa' }
    end

    context 'get from file' do
      before { subject.body = nil }
      before { File.write(subject.filename, 'aaaa') }
      its(:body) { should == 'aaaa' }
    end
  end
  
  context '#save_with_file' do
    context 'save if body exists' do
      before { subject.body = 'aaaa' }
      before { subject.save }
      it { expect(File.read(subject.filename)).to eql('aaaa') }
    end

    context 'does not save if body does not exist' do
      before { subject.body = nil }
      before { subject.save }
      it { expect(File.exist?(subject.filename)).to be_false }
    end
  end

  context '#destroy_with_file' do
    context 'delete if file exists' do
      before { subject.save }
      before { subject.destroy }
      it { expect(File.exist?(subject.filename)).to be_false }
    end

    context 'fine even if file does not exist' do
      before { subject.destroy }
      it { expect(File.exist?(subject.filename)).to be_false }
    end
  end
end

