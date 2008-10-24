module ResourceController
  module Helpers
    module CurrentObjects
      protected
        # Used internally to return the model for your resource.  
        def model
          model_name.to_s.camelize.constantize
        end
        
        # Used to fetch the current member object in all of the singular methods that operate on an existing member.
        # Override this method if you'd like to fetch your objects in some alternate way, like using a permalink.
        
        # class PostsController < ResourceController::Base
        #   private
        #     def object
        #       @object ||= end_of_association_chain.find_by_permalink(param)
        #     end
        #   end
        def object
          if !param.nil? && !include_statement.blank?
            @object ||= end_of_association_chain.find(param, include_statement) 
          elsif !param.nil?
            @object ||= end_of_association_chain.find(param) 
          end
            
          @object
        end
  
        # Used to fetch the collection for the index method
        # In order to customize the way the collection is fetched, to add something like pagination, for example, override this method.
        def collection
          if !include_statement.blank? && !object_params.blank?
            end_of_association_chain.find(:all, include_statement.merge(object_params))
          elsif !include_statement.blank?
            end_of_association_chain.find(:all, include_statement)
          elsif !object_params.blank?
            end_of_association_chain.find(:all, object_params)
          else
            end_of_association_chain.find(:all)
          end
        end
    
        # Returns the current param.
        # Defaults to params[:id].
        # Override this method if you'd like to use an alternate param name.
        def param
          params[:id]
        end
        
        # Default is nothing but can be overridden to include object's associations
        # This include params is included in the xml response by default
        def include_statement
          (!object_params.blank? && !object_params[:include].blank?) ? 
             {:include => [object_params[:include]].flatten.map(&:to_sym)} : {}
        end
    
        # Used internally to load the member object in to an instance variable @#{model_name} (i.e. @post)
        def load_object
          instance_variable_set "@#{parent_type}", parent_object if parent?
          instance_variable_set "@#{object_name}", object
        end
    
        # Used internally to load the collection in to an instance variable @#{model_name.pluralize} (i.e. @posts)
        def load_collection
          instance_variable_set "@#{parent_type}", parent_object if parent?
          instance_variable_set "@#{object_name.to_s.pluralize}", collection
        end
  
        # Returns the form params.  Defaults to params[model_name] (i.e. params["post"])
        def object_params
          params["#{object_name}"].symbolize_keys unless params[object_name.to_s].blank?
        end
    
        # Builds the object, but doesn't save it, during the new, and create action.
        def build_object
          @object ||= end_of_association_chain.send parent? ? :build : :new, object_params
        end
    end
  end
end
