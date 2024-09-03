class EnvironmentVariables::BulkUpdate
  extend LightService::Action

  expects :project, :params

  executed do |context|
    project = context.project
    context.params[:environment_variables].each do |environment_variable_params|
      name = environment_variable_params[:name].strip.upcase
      value = environment_variable_params[:value].strip
      environment_variable = project.environment_variables.find_by(name:) || project.environment_variables.build(name:)
      environment_variable.value = value
      environment_variable.save!
    end
  end
end