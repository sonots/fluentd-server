module ActsAsFile
  def self.included(klass)
    klass.extend(ClassMethods)
  end

  # ToDo: rename if filename is changed
  module ClassMethods
    # acts_as_file :field => self.instance_method(:filename)
    def acts_as_file(params = {})
      self.class_eval do
        unless method_defined?(:save_with_file)
          define_method(:save_with_file) do |*args|
            params.each do |field, filename_instance_method|
              field_name = :"@#{field}"
              filename = filename_instance_method.bind(self).call
              content  = self.instance_variable_get(field_name)
              File.open(filename, 'w') do |f|
                f.flock(File::LOCK_EX) # inter-process locking
                f.sync = true
                f.write(content)
                f.flush
              end if filename and content
            end
            save_without_file(*args)
          end
          alias_method :save_without_file, :save
          alias_method :save, :save_with_file

          params.each do |field, filename_instance_method|
            field_name = :"@#{field}"
            define_method("#{field}=") do |content|
              self.instance_variable_set(field_name, content)
            end
          end

          params.each do |field, filename_instance_method|
            field_name = :"@#{field}"
            define_method(field) do |offset = nil, length = nil|
              if offset || length
                # does not cache in this way
                filename = filename_instance_method.bind(self).call
                return nil unless filename
                return nil unless File.exist?(filename)
                File.open(filename) do |file|
                  file.seek(offset) if offset
                  file.read(length)
                end
              else
                content = self.instance_variable_get(field_name)
                return content if content
                # if (self.updated_at.nil? or File.mtime(filename) > self.updated_at)
                filename = filename_instance_method.bind(self).call
                return nil unless filename
                return nil unless File.exist?(filename)
                self.instance_variable_set(field_name, File.read(filename))
              end
            end
          end

          define_method(:destroy_with_file) do
            params.each do |field, filename_instance_method|
              field_name = :"@#{field}"
              filename = filename_instance_method.bind(self).call
              File.unlink(filename) if File.exist?(filename)
            end
            destroy_without_file
          end
          alias_method :destroy_without_file, :destroy
          alias_method :destroy, :destroy_with_file
        end
      end
    end
  end
end
