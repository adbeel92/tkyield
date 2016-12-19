namespace :csv do
  desc "it does a thing"
  task :export, [:model] => [:environment] do |t, args|
    require 'csv'
    if args[:model]
      model_plural = args[:model].pluralize
      class_name = args[:model].titleize.gsub(' ', '').constantize
      file_path = "#{Rails.root}/public/csv/#{model_plural}_#{Time.now.utc.strftime("%Y_%m_%d_%H_%M_%S")}.csv"
      dir = File.dirname(file_path)
      FileUtils.mkdir_p(dir) unless File.directory?(dir)
      CSV.open(file_path, "wb") do |csv|
        csv << class_name.attribute_names
        class_name.all.each do |object|
          csv << object.attributes.values
        end
      end
    else
      puts "You need to pass a model name"
    end
  end
end
