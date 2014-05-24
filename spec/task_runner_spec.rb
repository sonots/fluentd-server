require_relative 'spec_helper'
require 'fluentd_server/task_runner'
require 'fluentd_server/model'

describe 'TaskRunner' do
  let(:task) { Task.create }
  before { task.stub(:delay).and_return { task } }
  after { Task.delete_all }

  context '.serf_path' do
    it { expect(File.executable?(Task.serf_path)).to be_true }
  end

  # ToDo: Test whether the serf command is executed correctly
  context '#restart' do
    it { expect { task.restart }.not_to raise_error }
  end

  context '#status' do
    it { expect { task.status }.not_to raise_error }
  end

  context '#configrest' do
    it { expect { task.configtest }.not_to raise_error }
  end
end

