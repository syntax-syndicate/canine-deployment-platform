class Clusters::InstallCertManager
  extend LightService::Action

  expects :cluster

  executed do |context|
    cluster = context.cluster
    K8::Kubectl.new(cluster.kubeconfig).with_kube_config do |kubeconfig_path|
      env_vars = {
        "KUBECONFIG" => kubeconfig_path.path,
      }

      # Construct the command
      command = env_vars.map { |k, v| "#{k}=#{v}" }.join(" ") + " bash #{Rails.root.join("resources", "k8", "scripts", "install_cert_manager.sh")}"
      Open3.popen3(command) do |stdin, stdout, stderr, wait_thr|
        stdin.close # We're not providing input to the script
      
        # Read stdout and stderr in separate threads to avoid blocking
        out_reader = Thread.new do
          stdout.each_line { |line| cluster.append_log_line(line.chomp) }
        end
      
        err_reader = Thread.new do
          stderr.each_line { |line| cluster.append_log_line(line.chomp) }
        end
      
        # Wait for threads to finish
        out_reader.join
        err_reader.join
      
        exit_status = wait_thr.value
        if exit_status.success?
          cluster.running!
          cluster.append_log_line("Installed cluster successfully")
        else
          cluster.append_log_line("Failed to install cluster: #{exit_status.exitstatus}")
          cluster.fail!
          context.fail!("Script failed with exit code #{exit_status.exitstatus}")
        end
      end
    end
  end
end