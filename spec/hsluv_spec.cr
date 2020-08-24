require "json"

require "./spec_helper"

# Turns a color array in a JSON::Any into a literal StaticArray(Float32, 3)
def unwrap_sample(node : JSON::Any) : StaticArray(Float64, 3)
  arr = node.as_a

  StaticArray(Float64, 3).new do |idx|
    el = arr[idx]
    (el.as_f? || el.as_i? || el.as_f32).to_f64
  end
end

# Returns true if each element of two float arrays differ by less than 1e-11
def deviation(arr1, arr2)
  arr1.zip(arr2).each do |group|
    return false if (group.last - group.first).abs > 1e-11
  end

  true
end

describe HSLuv do
  describe "snapshot" do
    snapshot = JSON.parse(File.read("./spec/snapshot-rev4.json"))

    snapshot.as_h.each do |hex, values|
      test_rgb = unwrap_sample values["rgb"]
      test_xyz = unwrap_sample values["xyz"]
      test_luv = unwrap_sample values["luv"]
      test_lch = unwrap_sample values["lch"]
      test_hsluv = unwrap_sample values["hsluv"]
      test_hpluv = unwrap_sample values["hpluv"]

      context "should convert #{hex}" do
        # Forward

        it "from rgb to xyz" do
          deviation(HSLuv.rgb_to_xyz(test_rgb), test_xyz).should eq true
        end

        it "from xyz to luv" do
          deviation(HSLuv.xyz_to_luv(test_xyz), test_luv).should eq true
        end

        it "from luv to lch" do
          deviation(HSLuv.luv_to_lch(test_luv), test_lch).should eq true
        end

        it "from lch to hsluv" do
          deviation(HSLuv.lch_to_hsluv(test_lch), test_hsluv).should eq true
        end

        it "from lch to hpluv" do
          deviation(HSLuv.lch_to_hpluv(test_lch), test_hpluv).should eq true
        end

        # Backward
        it "from hpluv to lch" do
          deviation(HSLuv.hpluv_to_lch(test_hpluv), test_lch).should eq true
        end

        it "from hsluv to lch" do
          deviation(HSLuv.hsluv_to_lch(test_hsluv), test_lch).should eq true
        end

        it "from lch to luv" do
          deviation(HSLuv.lch_to_luv(test_lch), test_luv).should eq true
        end

        it "from luv to xyz" do
          deviation(HSLuv.luv_to_xyz(test_luv), test_xyz).should eq true
        end

        it "from xyz to rgb" do
          deviation(HSLuv.xyz_to_rgb(test_xyz), test_rgb).should eq true
        end

        # Others
        it "from hsluv to hex" do
          h, s, l = test_hsluv
          HSLuv.hsluv_to_hex(h, s, l).should eq hex
        end

        it "from hpluv to hex" do
          h, s, l = test_hpluv
          HSLuv.hpluv_to_hex(h, s, l).should eq hex
        end

        it "from hex to hsluv" do
          deviation(HSLuv.hex_to_hsluv(hex), test_hsluv).should eq true
        end

        it "from hex to hpluv" do
          deviation(HSLuv.hex_to_hpluv(hex), test_hpluv).should eq true
        end
      end
    end
  end
end
