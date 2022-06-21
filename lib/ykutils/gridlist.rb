require 'ykutils/erubyx'

module Ykutils
  module Gridlist
    TAMPLETES = { :GRID_DEF => 
      { :TEMPLATE => %!
    .g-<%= row %>-<%= colum %> {
      grid-row-start: <%= row %>;
      grid-row-end: ,<%= row + 1 %>;
      grid-column-start: <%= colum %>;
      grid-column-end: <%= colum + 1 %>;
    }
    ! , :OBJ => nil } }

    module_function

    def make_one_grid(hash, row, colum)
      unless hash[:OBJ]
        hash[:OBJ] = Tilt::ErubiTemplate.new{ hash[:TEMPLATE] }
      end
      hash[:OBJ].render( Object.new, {row: row, colum: colum} )
    end

    def make_grid(template_hash, scope, min_row, max_row, min_colum, max_colum)
=begin
      p min_row
      p max_row
      p min_colum
      p max_colum
=end
      (min_row..max_row).map { |row|
        (min_colum..max_colum).map { |colum|
          #puts "#{row} #{colum}"
          value_hash = { row: row, colum: colum }
          #make_one_grid(template_hash, value_hash)
          p template_hash
          p value_hash
          Ykutils::Erubyx::erubi_render(template_hash, scope, value_hash)
        }
      }
    end

    def make_grid_list()
      template_hash = TAMPLETES[:GRID_DEF]
      scope = nil
=begin
      min_row = 1
      max_row = 2
      min_colum = 1
      max_colum = 5
=end
      make_grid(template_hash, scope, min_row, max_row, min_colum, max_colum)
    end

    def make_grid_list_x(min_row, max_row, min_colum, max_colum)
      template_hash = TAMPLETES[:GRID_DEF]
      scope = nil
=begin
      p min_row
      p max_row
      p min_colum
      p max_colum
~end
      make_grid(template_hash, scope, min_row, max_row, min_colum, max_colum)
    end
  end
end
