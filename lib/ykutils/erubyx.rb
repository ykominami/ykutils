require 'tilt'
require 'yaml'

module Ykutils
  module Erubyx
    module_function

    def erubi_render(template_hash, scope, value_hash = {})
      unless template_hash[:OBJ]
        template_hash[:OBJ] = Tilt::ErubiTemplate.new{ template_hash[:TEMPLATE] }
      end
      template_hash[:OBJ].render( scope, value_hash )
    end

##
# `erubi_render_with_file` takes a template file path, a scope, and a value file path, reads the
# template file, loads the value file, and then calls `erubi_render` with the template hash, scope,
# and value hash
# 
# Args:
#   template_file_path: The path to the template file.
#   scope: the scope of the template. This is the name of the directory that the template is in.
#   value_file_path: The path to the YAML file that contains the values to be used in the template.
    def erubi_render_with_file(template_file_path, scope, value_file_path_array)
      template_text = File.read(template_file_path)
      template_hash = { TEMPLATE: template_text,
                        OBJ: nil
                      }
      value_hash = value_file_path_array.reduce({}){ |hash, path|
        #p path
        hash0 = YAML.load_file(path)
        #p hash0
        hash = hash.merge(hash0)
        #p hash
        hash
      }
      #puts value_hash
      erubi_render(template_hash, scope, value_hash)
    end

    def erubi_render_with_template_file(template_file_path, scope, value_hash = {})
      template_text = File.read(template_file_path)
      template_hash = make_template_hash( template_text )
      #puts value_hash
      erubi_render(template_hash, scope, value_hash)
    end

    def make_template_hash( text )
        { TEMPLATE: text,
          OBJ: nil}
    end
  end
end
