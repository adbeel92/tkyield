module ProjectsHelper
	def projects_helper
		projects = current_user.projects.order("name ASC").includes(:client)
		grouped_options = projects.inject({}) do |options, project|
			(options[project.client_name] ||= []) << [project.name, project.id]
			options
		end
		return grouped_options
	end
end
