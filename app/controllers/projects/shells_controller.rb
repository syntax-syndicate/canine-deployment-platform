class Projects::ShellsController < Projects::BaseController
  before_action :set_project
  def show
  end

  def input
    pod_name = session[:pod_name]
    input = params[:input]

    # Connect to the pod and pass the input
    exec_options = {
      stdin: StringIO.new(input),
      tty: true
    }

    response = client.exec(pod_name, 'busybox', exec_options)

    # Send the response back to the frontend
    render json: { output: response }
  end

  def create
    # Initialize the connection to the Kubernetes cluster
    config = Kubeclient::Config.read('/path/to/kubeconfig')
    client = Kubeclient::Client.new(
      config.context.api_endpoint,
      'v1',
      ssl_options: config.context.ssl_options,
      auth_options: config.context.auth_options
    )

    # Start a pod with busybox
    pod = Kubeclient::Resource.new
    pod.metadata = { name: 'busybox-shell' }
    pod.spec = {
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
    client.create_pod(pod)

    # Get the pod's name and store it in the session
    session[:pod_name] = pod.metadata.name

    render json: { success: true }
  end

  def destroy
    pod_name = session[:pod_name]
    client.delete_pod(pod_name, 'default')

    render json: { success: true }
  end

  #def client
  #  @client ||= Kubeclient::Client.new(
  #    config.context.api_endpoint,
  #    'v1',
  #    ssl_options: config.context.ssl_options,
  #    auth_options: config.context.auth_options
  #  )
  #end

  #def config
  #  @config ||= Kubeclient::Config.read('/path/to/kubeconfig')
  #end
end