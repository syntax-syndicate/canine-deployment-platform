require 'aws-sdk-ecr'

class ContainerRegistryService
  def initialize(region: 'us-west-2')
    @ecr_client = Aws::ECR::Client.new(region: region)
  end

  def create_repository(repo_name)
    response = @ecr_client.create_repository({
      repository_name: repo_name
    })

    response.repository.repository_uri
  rescue Aws::ECR::Errors::ServiceError => e
    Rails.logger.error "Failed to create ECR repository: #{e.message}"
    nil
  end
end
