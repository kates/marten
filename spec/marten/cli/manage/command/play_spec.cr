require "./spec_helper"

describe Marten::CLI::Manage::Command::Play do
  describe "#run" do
    it "starts the Crystal playground as expected when no host/port are provided" do
      stdout = IO::Memory.new
      stderr = IO::Memory.new

      command = Marten::CLI::Manage::Command::Play.new(
        options: ["--no-open"],
        stdout: stdout,
        stderr: stderr
      )

      spawn { command.handle }

      sleep 1

      command.playground_process.try(&.terminate)

      stderr.rewind.gets_to_end.empty?.should be_true
    end

    it "starts the Crystal playground as expected when a host is provided" do
      stdout = IO::Memory.new
      stderr = IO::Memory.new

      command = Marten::CLI::Manage::Command::Play.new(
        options: ["--no-open", "--bind", "localhost"],
        stdout: stdout,
        stderr: stderr
      )

      spawn { command.handle }

      sleep 1

      command.playground_process.try(&.terminate)

      stderr.rewind.gets_to_end.empty?.should be_true
    end

    it "starts the Crystal playground as expected when a port is provided" do
      stdout = IO::Memory.new
      stderr = IO::Memory.new

      command = Marten::CLI::Manage::Command::Play.new(
        options: ["--no-open", "--port", "3000"],
        stdout: stdout,
        stderr: stderr
      )

      spawn { command.handle }

      sleep 1

      command.playground_process.try(&.terminate)

      stderr.rewind.gets_to_end.empty?.should be_true
    end

    it "starts the Crystal playground as expected when a host and port are provided" do
      stdout = IO::Memory.new
      stderr = IO::Memory.new

      command = Marten::CLI::Manage::Command::Play.new(
        options: ["--no-open", "--bind", "localhost", "--port", "3000"],
        stdout: stdout,
        stderr: stderr
      )

      spawn { command.handle }

      sleep 1

      command.playground_process.try(&.terminate)

      stderr.rewind.gets_to_end.empty?.should be_true
    end
  end
end
