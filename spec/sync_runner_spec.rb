require_relative 'spec_helper'
require 'fluentd_server/sync_runner'

if FluentdServer::Config.local_storage
  describe 'SyncRunner' do
    def clean
      filenames = File.join(FluentdServer::Config.data_dir, '*.erb') 
      Dir.glob(filenames).each { |f| File.delete(f) rescue nil }
      Post.delete_all
    end
    around {|example| clean; example.run; clean }
    let(:runner) { FluentdServer::SyncRunner.new }

    context '#find_locals' do
      before { Post.create(name: 'post1', body: 'a') }
      before { Post.create(name: 'post2', body: 'a') }
      let(:subject) { runner.find_locals }
      it { should =~ ['post1', 'post2' ] }
    end

    context '#find_diff' do
      before { Post.new(name: 'post1').save_without_file }
      before { Post.create(name: 'post2', body: 'a') }
      before { File.open(Post.new(name: 'post3').filename, "w") {} }
      it {
        plus, minus = runner.find_diff
        expect(minus).to eql(['post1'])
        expect(plus).to eql(['post3'])
      }
    end

    context '#create' do
      before { Post.create(name: 'post1', body: 'a') }
      before { runner.create(%w[post1 post2]) }
      it {
        expect(Post.find_by(name: 'post1').body).not_to be_nil
        expect(Post.find_by(name: 'post2').body).to be_nil
      }
    end

    context '#delete' do
      before {
        post1 = Post.create(name: 'post1', body: 'a')
        post2 = Post.create(name: 'post2', body: 'a')
        runner.delete(%w[post1])
      }
      it {
        expect(Post.find_by(name: 'post1')).to be_nil
        expect(Post.find_by(name: 'post2')).not_to be_nil
      }
    end

    context '#run' do
      before { Post.new(name: 'post1').save_without_file }
      before { Post.create(name: 'post2', body: 'a') }
      before { File.open(Post.new(name: 'post3').filename, "w") {} }
      it {
        runner.run
        expect(Post.find_by(name: 'post1')).to be_nil
        expect(Post.find_by(name: 'post2')).not_to be_nil
        expect(Post.find_by(name: 'post3')).not_to be_nil
      }
    end
  end
else
  describe 'SyncRunner' do
    context '#run' do
      let(:subject) { FluentdServer::SyncRunner.new.run }
      it { should be_nil }
    end
    context '#find_locals' do
      before { Post.create(name: 'post1', body: 'a') }
      before { Post.create(name: 'post2', body: 'a') }
      let(:subject) { FluentdServer::SyncRunner.new.find_locals }
      it { should == [] }
    end
  end
end
