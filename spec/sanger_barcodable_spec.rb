require 'sanger_barcodeable'
require 'spec_helper'

shared_examples_for "a barcode" do
  it "converts prefix to a number" do
    Barcode.prefix_to_number(human_prefix).should eq(machine_prefix*1000000000)
  end

  it "calculates the full barcode" do
    Barcode.calculate_barcode(human_prefix,short_barcode).should eq(ean13)
  end

  it "calculates a checksum" do
    Barcode.calculate_checksum(human_prefix,short_barcode).should eq(human_checksum)
  end

  it "splits a barcode into its components" do
    # Seems wrong, why is machine prefix a string, but the rest integers?
    Barcode.split_barcode(ean13).should eq([machine_prefix.to_s,short_barcode,machine_checksum])
  end

  it "splits a human barcode into its components" do
    Barcode.split_human_barcode(human_full).should eq([human_prefix,short_barcode.to_s,human_checksum])
  end

  it "converts machine_barcodes to human" do
    # This method seems badly named to me. Human implies the full 'PR1234K' barcode, not just
    # the short 'barcode' number as stored in the database.
    Barcode.number_to_human(ean13).should eq(short_barcode.to_s)
  end

  it "gets the human prefix from the ean13 barcode" do
    Barcode.prefix_from_barcode(ean13).should eq('PR')
  end

  it "can convert numeric prefixes to human" do
    Barcode.prefix_to_human(machine_prefix).should eq(human_prefix)
  end

  it "can convert between human barcodes and machine barcodes" do
    Barcode.human_to_machine_barcode(human_full).should eq(ean13)
    Barcode.barcode_to_human(ean13).should eq(human_full)
  end

  it "can convert to human barcodes with a prefix check" do
    Barcode.barcode_to_human!(ean13, human_prefix).should eq(human_full)
    expect {
      Barcode.barcode_to_human!(ean13, 'XX')
    }.to raise_error
  end

  it "has a vaild ean13" do
    Barcode.check_EAN(ean13).should eq(true)
  end

  it "can freely convert between them using the new models" do
    Barcode::HumanBarcode.new(human_full).human_barcode.should eq(human_full)
    Barcode::HumanBarcode.new(human_full).machine_barcode.should eq(ean13)
    Barcode::MachineBarcode.new(ean13).human_barcode.should eq(human_full)
    Barcode::MachineBarcode.new(ean13).machine_barcode.should eq(ean13)
    Barcode::BuiltBarcode.new(human_prefix,short_barcode).human_barcode.should eq(human_full)
    Barcode::BuiltBarcode.new(human_prefix,short_barcode).machine_barcode.should eq(ean13)
  end

  # This method doesn't appear to be used externally, only in barcode generation
  # it "can find an ean13" do
  #   Barcode.calculate_EAN13(pre_ean13).should eq(print_checksum)
  # end
end

describe Barcode do

  context "with valid parameters" do

    let (:human_prefix) {'PR'}
    let (:human_checksum) {'K'}
    let (:human_full) {'PR1234K'}
    let (:short_barcode) {1234}

    let (:machine_prefix) {450}
    let (:ean13) {4500001234757}
    let (:pre_ean13) {450000123475}
    let (:machine_checksum) {75}
    let (:print_checksum) {7}

    it_behaves_like "a barcode"
  end

  context "with invalid parameters" do

    let (:human_prefix) {'XX'}
    let (:human_checksum) {'X'}
    let (:human_full) {'XX1234X'}
    let (:short_barcode) {1234}

    let (:machine_prefix) {450}
    let (:ean13) {4500101234757}
    let (:pre_ean13) {450010123475}
    let (:machine_checksum) {75}
    let (:print_checksum) {7}

    it "has a invaild ean13" do
      Barcode.check_EAN(ean13).should eq(false)
    end

    it "will raise on conversion" do
      expect {
        Barcode.barcode_to_human!(ean13, 'XX')
      }.to raise_error
      expect {
        Barcode.human_to_machine_barcode(human_full)
      }.to raise_error
    end

  end

  context "which is too long" do
    let (:human_prefix) {'PR'}
    let (:short_barcode) {12345678}

    it "will raise an exception" do
      expect {
        Barcode.calculate_barcode(human_prefix,short_barcode)
      }.to raise_error
    end
  end

end
