module Permoid

  module Base
    def self.included(klass)
      klass.class_eval do
        raise if !self.include? Mongoid::Document


        field                    :permalink
        before_validation        :set_permalink
        index :permalink

        def set_permalink(permalink = nil)
          return if self.field_permalink.nil?
          permalink = permalink.nil? ? self.field_permalink.to_permalink : permalink

          others = self.class.where(:permalink => permalink)
          others = others.excludes(:id => self.id) unless self.new_record?
          index = 0
          while !others.empty?
            index += 1
            others = self.class.where(:permalink => "#{permalink}-#{index}")
          end

          self.permalink = index > 0 ? "#{permalink}-#{index}" : permalink
        end

        def to_param
          self.permalink
        end

        def field_permalink
          send(@@field_permalink)
        end

        def self.field_permalink(field)
          raise Permoid::ConfigurationError.new('You need define a field_permalink already a field in your model') unless fields.has_key?(field.to_s)
          raise Permoid::ConfigurationError.new('You need define a field_permalink with a field with type String') unless fields[field.to_s].type == ''.class
          @@field_permalink = field
        end
      end
    end

  end
end
