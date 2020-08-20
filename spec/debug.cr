require "../src/hsluv-crystal"


# 1) HSLuv snapshot should convert #000022 from hsluv to hex
#      Failure/Error: HSLuv.hsluv_to_hex(h, s, l).should eq hex
# 
#        Expected: "#000022"
#             got: "#000021"
# 
#      # spec/hsluv-crystal_spec.cr:87
# 
#   2) HSLuv snapshot should convert #000022 from hpluv to hex
#      Failure/Error: HSLuv.hpluv_to_hex(h, s, l).should eq hex
# 
#        Expected: "#000022"
#             got: "#000021"
# 
#      # spec/hsluv-crystal_spec.cr:92
# 
#   3) HSLuv snapshot should convert #000055 from hsluv to hex
#      Failure/Error: HSLuv.hsluv_to_hex(h, s, l).should eq hex
# 
#        Expected: "#000055"
#             got: "#000054"
# 
#      # spec/hsluv-crystal_spec.cr:87
# 
#   4) HSLuv snapshot should convert #000055 from hpluv to hex
#      Failure/Error: HSLuv.hpluv_to_hex(h, s, l).should eq hex
# 
#        Expected: "#000055"
#             got: "#000054"
# 
#      # spec/hsluv-crystal_spec.cr:92
# 
#   5) HSLuv snapshot should convert #000088 from hsluv to hex
#      Failure/Error: HSLuv.hsluv_to_hex(h, s, l).should eq hex
# 
#        Expected: "#000088"
#             got: "#000087"



# {
#   "#000022": {
#     "rgb": [
#       0,
#       0,
#       0.13333333333333333
#     ],
#     "xyz": [
#       0.002887023638114141,
#       0.0011548094552456725,
#       0.015204991160734828
#     ],
#     "luv": [
#       1.0431351037401557,
#       -0.3036444573679825,
#       -4.20960128950726
#     ],
#     "lch": [
#       1.0431351037401557,
#       4.22053823263236,
#       265.8743202181779
#     ],
#     "hsluv": [
#       265.8743202181779,
#       100.00000000000084,
#       1.0431351037401557
#     ],
#     "hpluv": [
#       265.8743202181779,
#       513.4126968442803,
#       1.0431351037401557
#     ]
#   }
# }

color = "#000022"

p HSLuv.hex_to_hsluv(color)
# p HSLuv.hsluv_to_hex(*HSLuv.hex_to_hsluv(color))
