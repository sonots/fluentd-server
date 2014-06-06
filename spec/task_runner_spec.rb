require_relative 'spec_helper'
require 'fluentd_server/task_runner'
require 'fluentd_server/model'

describe 'TaskRunner' do
  let(:task) { Task.create }
  before { allow(task).to receive(:delay).and_return(task) }
  after { Task.delete_all }

  context '.serf_path' do
    it { expect(File.executable?(Task.serf_path)).to be_truthy }
  end

  # ToDo: Test whether the serf command is executed correctly
  context '#restart' do
    it { expect { task.restart }.not_to raise_error }
  end

  context '#status' do
    it { expect { task.status }.not_to raise_error }
  end

  context '#configtest' do
    it { expect { task.configtest }.not_to raise_error }
  end
end

