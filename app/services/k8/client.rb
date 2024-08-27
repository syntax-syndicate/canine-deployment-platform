module K8
  class Client
    def initialize(kubeconfig)
      @kubeconfig = kubeconfig
      @client = build_client
    end

    def can_connect?
      begin
        @client.discover
        true
      rescue StandardError => e
        puts "Connection failed: #{e.message}"
        false
      end
    end

    private

    def load_kubeconfig(kubeconfig_string)
      YAML.safe_load(kubeconfig_string)
    rescue Psych::SyntaxError => e
      raise "Invalid YAML in kubeconfig: #{e.message}"
    end

    def build_client
      kubecontext = @kubeconfig['current-context']
      cluster_name = @kubeconfig['contexts'].find { |ctx| ctx['name'] == kubecontext }['context']['cluster']
      user_name = @kubeconfig['contexts'].find { |ctx| ctx['name'] == kubecontext }['context']['user']

      cluster_info = @kubeconfig['clusters'].find { |cl| cl['name'] == cluster_name }['cluster']
      user_info = @kubeconfig['users'].find { |usr| usr['name'] == user_name }['user']

      Kubeclient::Client.new(
        cluster_info['server'],
        'v1',
        ssl_options: ssl_options(cluster_info),
        auth_options: auth_options(user_info)
      )
    end

    def ssl_options(cluster_info)
      ssl_options = { verify_ssl: OpenSSL::SSL::VERIFY_NONE }
      if cluster_info['certificate-authority-data']
        ssl_options[:ca_file] = write_temp_file(Base64.decode64(cluster_info['certificate-authority-data']))
      end
      ssl_options
    end

    def auth_options(user_info)
      auth_options = {}
      if user_info['client-certificate-data'] && user_info['client-key-data']
        auth_options[:client_cert] = OpenSSL::X509::Certificate.new(Base64.decode64(user_info['client-certificate-data']))
        auth_options[:client_key] = OpenSSL::PKey::RSA.new(Base64.decode64(user_info['client-key-data']))
      elsif user_info['token']
        auth_options[:bearer_token] = user_info['token']
      end
      auth_options
    end

    def write_temp_file(content)
      file = Tempfile.new
      file.write(content)
      file.close
      file.path
    end
  end
end

