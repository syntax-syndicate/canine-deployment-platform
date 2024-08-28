class ShellChannel < ApplicationCable::Channel
  def subscribed
    # Subscribe to the shell session specific to a project
    @project_id = params[:project_id]
    stream_from "shell_channel_#{params[:project_id]}"

    # Initialize the connection to Kubernetes and start the busybox pod for this project
    pod = Kubeclient::Resource.new(
      metadata: {
        name: "busybox-shell-#{params[:project_id]}",
        namespace: 'default'  # Ensure the namespace is set correctly
      },
      spec: {
        containers: [
          {
            name: 'busybox',
            image: 'busybox',
            command: ['sh'],
            tty: true,
            stdin: true
          }
        ],
        restartPolicy: 'Never'
      }
    )
    #client.client.create_pod(pod)
    #ActionCable.server.broadcast("shell_channel_#{params[:project_id]}", {message: 'Shell is ready. You can start typing commands.'})
  end

  def receive(data)
    # Handle incoming data from the client specific to the project's shell
    pod_name = "busybox-shell-#{params[:project_id]}"
    project = Project.find(params[:project_id])
    stdout, stderr, status = K8::Kubectl.from_project(project).run("exec -it #{pod_name} -- #{data['input']}")
    ActionCable.server.broadcast("shell_channel_#{params[:project_id]}", {output: stdout, error: stderr, status: status})
  end

  def unsubscribed
    # Clean up when the project's shell is disconnected
    #pod_name = "busybox-shell-#{params[:project_id]}"
    #client.client.delete_pod(pod_name, 'default')
  end

  private
  def client
    @client ||= K8::Client.from_project(Project.find(params[:project_id] || @project_id))
  end
end
