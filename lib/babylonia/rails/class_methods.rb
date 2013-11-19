module Babylonia
  module ClassMethods
    def build_babylonian_tower_on_with_activerecord_patch *fields
      fields.each do |field|
        define_method field do
          super()
        end
        
        define_method :"#{field}=" do |data|
          super(data)
        end
      end
      
      build_babylonian_tower_on_without_activerecord_patch *fields
    end
    alias_method :build_babylonian_tower_on_without_activerecord_patch, :build_babylonian_tower_on
    alias_method :build_babylonian_tower_on, :build_babylonian_tower_on_with_activerecord_patch

  end
end