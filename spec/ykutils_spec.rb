# frozen_string_literal: true

RSpec.describe Ykutils do
  it "has a version number" do
    expect(Ykutils::VERSION).not_to be nil
  end

#  it "does something useful" do
#    expect(false).to eq(true)
#  end
  describe "Ykutils::Erubyx" do
    it "make_grid_list" do
      expect(Ykutils::VERSION).not_to be nil
    end

    it "make_grid" do
      expect(Ykutils::Gridlist::make_grid_list()).to be nil
    end
  end
end
