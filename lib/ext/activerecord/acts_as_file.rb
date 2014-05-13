module ActiveRecord; end

module ActiveRecord::ActsAsFile
  def self.included(klass)
    klass.extend(ClassMethods)
  end

  # ToDo: rename if filename is changed
  module ClassMethods
    # acts_as_file :field, :filename => self.instance_method(:filename)
    def acts_as_file(field, options = {})
      filename_instance_method = options[:filename]
      field_name = :"@#{field}" 
      self.class_eval do
        unless method_defined?(:save_with_file)
          define_method(:save_with_file) do
            filename = filename_instance_method.bind(self).call
            content  = self.instance_variable_get(field_name)
            File.open(filename, 'w') do |f|
              f.flock(File::LOCK_EX) # inter-process locking
              f.sync = true
              f.write(content)
              f.flush
            end if filename and content
            save_without_file
          end
          alias_method :save_without_file, :save
          alias_method :save, :save_with_file

          define_method("#{field}=") do |content|
            self.instance_variable_set(field_name, content)
          end

          define_method(field) do
            content = self.instance_variable_get(field_name)
            return content if content
            # if (self.updated_at.nil? or File.mtime(filename) > self.updated_at)
            filename = filename_instance_method.bind(self).call
            return nil unless filename
            return nil unless File.exist?(filename)
            self.instance_variable_set(field_name, File.read(filename))
          end

          define_method(:destroy_with_file) do
            filename = filename_instance_method.bind(self).call
            File.unlink(filename) if File.exist?(filename)
            destroy_without_file
          end
          alias_method :destroy_without_file, :destroy
          alias_method :destroy, :destroy_with_file
        end
      end
    end
  end
end
