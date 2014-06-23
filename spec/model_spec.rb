require_relative 'spec_helper'
require 'fluentd_server/model'
require 'paper_trail'

describe Delayed::Job do
end

describe Post do
  it do
    ENV['STORE_HISTORY'] = 'false'
    load 'fluentd_server/model.rb'
    should_not be_versioned
  end

  it do
    ENV['STORE_HISTORY'] = 'true'
    load 'fluentd_server/model.rb'
    should be_versioned
  end
end

describe Task do
  after { Task.delete_all }

  context '#new?' do
    it { expect(Task.new.new?).to be_truthy }
    it { expect(Task.create.new?).to be_falsey }
  end

  context '#filename' do
    it { expect(Task.new.filename).to be_nil }
    it { expect(Task.create.filename).to be_kind_of(String) }
  end

  context '#create_and_delete' do
    before { allow(FluentdServer::Config).to receive(:task_max_num).and_return(1) }
    before { @oldest = Task.create(name: 'Restart') }
    it {
      Task.create_and_delete(name: 'Restart')
      expect(Task.find_by(id: @oldest.id)).to be_nil
      expect(Task.count).to eql(1)
    }
  end
end

