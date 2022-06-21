require 'tilt'

module Ykutils
  module Erubyx
    module_function

    def erubi_render(template_hash, scope, value_hash)
      unless template_hash[:OBJ]
        template_hash[:OBJ] = Tilt::ErubiTemplate.new{ template_hash[:TEMPLATE] }
      end
      template_hash[:OBJ].render( scope, value_hash )
    end
  end
end
