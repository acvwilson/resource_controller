module ResourceController
  module Controller    
    def self.included(subclass)
      subclass.class_eval do
        include ResourceController::Helpers
        include ResourceController::Actions
        extend  ResourceController::Accessors
        extend  ResourceController::ClassMethods
        
        class_reader_writer :belongs_to, *NAME_ACCESSORS
        NAME_ACCESSORS.each { |accessor| send(accessor, controller_name.singularize.underscore) }

        ACTIONS.each do |action|
          class_scoping_reader action, FAILABLE_ACTIONS.include?(action) ? FailableActionOptions.new : ActionOptions.new
        end

        self.helper_method :object_url, :edit_object_url, :new_object_url, :collection_url, :object, :collection, 
                             :parent, :parent_type, :parent_object, :parent_model, :model_name, :model, :object_path, 
                             :edit_object_path, :new_object_path, :collection_path, :hash_for_collection_path, :hash_for_object_path, 
                                :hash_for_edit_object_path, :hash_for_new_object_path, :hash_for_collection_url, 
                                  :hash_for_object_url, :hash_for_edit_object_url, :hash_for_new_object_url, :parent?,
                                    :collection_url_options, :object_url_options, :new_object_url_options
                                
      end
      
      init_default_actions(subclass)
    end
        
    private
      def self.init_default_actions(klass)
        klass.class_eval do
          index.wants.xml {render :xml => collection.to_xml(include_statement)}
          edit.wants.xml {render :xml => object.to_xml(include_statement)}
          new_action.wants.xml {render :xml => object.to_xml(include_statement)}

          show do
            wants.xml {render :xml => object.to_xml(include_statement)}

            failure.wants.xml {render :xml => object.to_xml(include_statement)}
          end

          create do
            flash "Successfully created!"
            wants.xml {render :xml => object.to_xml(include_statement)}

            failure.wants.xml {render :xml => object.to_xml(include_statement)}
          end

          update do
            flash "Successfully updated!"
            wants.xml {render :xml => object.to_xml(include_statement)}

            failure.wants.xml {render :xml => object.to_xml(include_statement)}
          end

          destroy do
            flash "Successfully removed!"
            wants.xml {render :xml => object.to_xml(include_statement)}
          end
          
          class << self
            def singleton?
              false
            end
          end
        end
      end
  end
end