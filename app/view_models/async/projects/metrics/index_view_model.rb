class Async::Projects::Metrics::IndexViewModel < Async::BaseViewModel
  include MetricsHelper
  include StorageHelper
  expects :project_id

  def project
    @project ||= current_user.projects.find(params[:project_id])
  end

  def metrics
    @metrics ||= project.cluster.metrics.for_project(project).order(created_at: :desc).limit(1000)
  end

  def pods
    @pods ||= K8::Metrics::Api::Pod.fetch(project.cluster, project.name)
  end

  def initial_render
    render "shared/components/skeleton_row"
  end

  def render_error
    "<div class='text-red-500'>Something went wrong rendering metrics</div>"
  end

  def async_render
    render "projects/metrics/async", locals: { pods:, metrics: }
  end

  def parse_cpu_metrics(metrics)
    cpu_metrics = metrics.select { |m| m.cpu? }
    cpu_metrics.group_by { |m| m.tag_value("pod") }.map do |pod, metrics|
      data = metrics.each_with_object({}) do |metric, h|
        h[metric.created_at] = 100 * metric.metadata.dig("cpu") / metric.metadata.dig("total_cpu")
      end
      { name: pod, data: }
    end
  end

  helper_method :parse_cpu_metrics

  def parse_memory_metrics(metrics)
    memory_metrics = metrics.select { |m| m.memory? }
    memory_metrics.group_by { |m| m.tag_value("pod") }.map do |pod, metrics|
      data = metrics.each_with_object({}) do |metric, h|
        h[metric.created_at] = 100 * metric.metadata.dig("memory") / metric.metadata.dig("total_memory")
      end
      { name: pod, data: }
    end
  end

  helper_method :parse_memory_metrics
end
