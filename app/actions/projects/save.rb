class Projects::Save
  extend LightService::Action

  expects :project
  promises :project

  executed do
    context.project.save!
  end
end