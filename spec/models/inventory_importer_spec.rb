require 'rails_helper'

RSpec.describe InventoryImporter do

  let(:import_file) { file_fixture("inventory_tally.csv") }
  let(:tally_object_count) { File.foreach(import_file).count - 1 } # subtract a row for the header
  subject { described_class.new(import_file) }

  context "when no locations or inventory types exist" do
    it "creates a tally object for each row in csv" do
      expect { subject.perform }.to change { InventoryTally.count }.by(tally_object_count)
    end

    it "creates inventory_adjustments for each tally" do
      expect { subject.perform }.to change { InventoryAdjustment.count }.by(tally_object_count)
    end

    it "creates a location object for each location in csv" do
      expect { subject.perform }.to change { Location.count }.by(3)
    end

    it "creates an inventory type for each type in csv" do
      expect { subject.perform }.to change { InventoryType.count }.by(3)
    end
  end

  context "when some locations exist" do

    let!(:location) { Location.create(name: "store-a-lot") }

    it "creates a tally object for each row in csv" do
      expect { subject.perform }.to change { InventoryTally.count }.by(tally_object_count)
    end

    it "creates inventory_adjustments for each tally" do
      expect { subject.perform }.to change { InventoryAdjustment.count }.by(tally_object_count)
    end

    it "creates a location object for new locations in csv" do
      expect { subject.perform }.to change { Location.count }.by(2)
      expect(location.inventory_tallies.count).to eq(2)
    end

    it "creates an inventory type for each type in csv" do
      expect { subject.perform }.to change { InventoryType.count }.by(3)
    end
  end

  context "when some inventory types exist" do

    let!(:inventory_type) { InventoryType.create(name: "tampons") }

    it "creates a tally object for each row in csv" do
      expect { subject.perform }.to change { InventoryTally.count }.by(tally_object_count)
    end

    it "creates inventory_adjustments for each tally" do
      expect { subject.perform }.to change { InventoryAdjustment.count }.by(tally_object_count)
    end

    it "creates a location object for new locations in csv" do
      expect { subject.perform }.to change { Location.count }.by(3)
    end

    it "creates an inventory type for each type in csv" do
      expect { subject.perform }.to change { InventoryType.count }.by(2)
      expect(inventory_type.inventory_tallies.count).to eq(2)
    end

    it "performs case-insensitive search" do
      inventory_type.update!(name: "Tampons")
      expect { subject.perform }.to change { InventoryType.count }.by(2) # "tampons" and "Tampons" are treated the same
      expect(inventory_type.inventory_tallies.count).to eq(2)
    end
  end

  context "when some inventory tallies are present" do
    before do
      location = Location.create(name: "store-a-lot")
      type = InventoryType.create(name: "tampons")
      tally = InventoryTally.create(storage_location: location, inventory_type: type)
      InventoryAdjustment.create(inventory_tally: tally, adjustment_quantity: 10)
    end

    it "creates a tally object for new tally combos in csv" do
      expect { subject.perform }.to change { InventoryTally.count }.by(tally_object_count - 1)
    end

    it "creates inventory_adjustments for each row" do
      expect { subject.perform }.to change { InventoryAdjustment.count }.by(tally_object_count)
    end

    it "creates a location object for new locations in csv" do
      expect { subject.perform }.to change { Location.count }.by(2)
    end

    it "creates an inventory type for each type in csv" do
      expect { subject.perform }.to change { InventoryType.count }.by(2)
    end
  end

  context "when invalid file path is provided" do
    let(:import_file) { "" }

    it { refute subject.perform }
  end

end