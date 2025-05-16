module Cli
  class Base
    def safely_kill(wait_thr)
      pid = wait_thr.pid
      Process.kill("TERM", pid)
      if wait_thr.join(0.1) # non-blocking wait
        return
      end
    rescue Errno::ESRCH
      # Process already terminated
    rescue
      Process.kill("KILL", pid) rescue nil
    end
  end

  class CommandFailedError < StandardError; end
  class RunAndReturnOutput < Base
    def call(command, envs: {})
      command = envs.map { |k, v| "#{k}=#{v}" }.join(" ") + " #{command}"
      output = `#{command.strip}`
      raise CommandFailedError, "Command `#{command}` failed with exit code #{$?.exitstatus}" unless $?.success?
      output
    end
  end

  class RunAndLog < Base
    def initialize(loggable)
      @loggable = loggable
    end

    def call(command, envs: {}, poll_every: nil, &block)
      command = envs.map { |k, v| "#{k}=#{v}" }.join(" ") + " #{command}"
      Open3.popen3(command.strip) do |stdin, stdout, stderr, wait_thr|
        stdin.close
        stdout.each_line { |line| @loggable.info(line.chomp) }
        stderr.each_line { |line| @loggable.info(line.chomp) }

        if poll_every.present?
          loop do
            sleep(poll_every)
            block.call(wait_thr)
          end
        end

        exit_status = wait_thr.value
        if exit_status.success?
          @loggable.success("Command succeeded")
        else
          raise CommandFailedError, "Command failed with exit code #{exit_status.exitstatus}"
        end
        exit_status
      end
    end
  end
end
