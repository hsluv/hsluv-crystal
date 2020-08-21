require "./hsluv-crystal"

# Single use type aliases for a 3x1 vector and a 3x3 matrix.
alias FloatVec = StaticArray(Float64, 3)
alias Matrix = StaticArray(FloatVec, 3)

# HSLuv is a perceptually uniform colorspace.
module HSLuv
  extend self
  VERSION = "0.1.0"

  M = Matrix [
      FloatVec [3.240969941904521, -1.537383177570093, -0.498610760293],
      FloatVec [-0.96924363628087, 1.87596750150772, 0.041555057407175],
      FloatVec [0.055630079696993, -0.20397695888897, 1.056971514242878],
  ]

  M_INV = Matrix [
      FloatVec [0.41239079926595, 0.35758433938387, 0.18048078840183],
      FloatVec [0.21263900587151, 0.71516867876775, 0.072192315360733],
      FloatVec [0.019330818715591, 0.11919477979462, 0.95053215224966],
  ]

  REF_Y = 1.0
  REF_U = 0.19783000664283
  REF_V = 0.46831999493879
  KAPPA = 903.2962962
  EPSILON = 0.0088564516

  ###

  # Converts an HSLuv color to a hexadecimal string.
  def hsluv_to_hex (h, s, l) : String
    r, g, b = hsluv_to_rgb(h, s, l)
    rgb_to_hex(r, g, b)
  end

  # Converts an HPLuv color to a hexadecimal string.
  def hpluv_to_hex (h, s, l) : String
    r, g, b = hpluv_to_rgb(h, s, l)
    rgb_to_hex(r, g, b)
  end

  # Converts a hexadecimal string to HSLuv, in h, s, l order
  def hex_to_hsluv (hex : String) : FloatVec
    r, g, b = hex_to_rgb(hex)
    rgb_to_hsluv(r, g, b)
  end

  # Converts a hexadecimal string to an HPLuv hsl array.
  def hex_to_hpluv (hex : String) : FloatVec
    r, g, b = hex_to_rgb(hex)
    rgb_to_hpluv(r, g, b)
  end

  # Converts an HSLuv color to an rgb array.
  def hsluv_to_rgb (h, s, l) : FloatVec
    xyz_to_rgb(luv_to_xyz(lch_to_luv(hsluv_to_lch([h, s, l]))))
  end

  # Converts an rgb color to an HSLuv hsl array.
  def rgb_to_hsluv (r, g, b) : FloatVec
    lch_to_hsluv(rgb_to_lch(r, g, b))
  end

  # Converts an HPLuv hsl color to an rgb array.
  def hpluv_to_rgb (h, s, l) : FloatVec
    l, c, h = hpluv_to_lch([h, s, l])
    lch_to_rgb(l, c, h)
  end

  # Converts an rgb color to an HPLuv hsl array.
  def rgb_to_hpluv (r, g, b) : FloatVec
    lch_to_hpluv(rgb_to_lch(r, g, b))
  end

  # Converts an LCh color to an rgb array.
  def lch_to_rgb (l, c, h) : FloatVec
    xyz_to_rgb(luv_to_xyz(lch_to_luv(FloatVec [l, c, h])))
  end

  # Converts an rgb color to an LCh array.
  def rgb_to_lch (r, g, b) : FloatVec
    luv_to_lch(xyz_to_luv(rgb_to_xyz(FloatVec [r, g, b])))
  end

  # Converts an rgb color to a hex color code - e.g.
  # rgb_to_hex(0xff, 0xaa, 0x88) == "#ffaa88"
  def rgb_to_hex (r, g, b) : String
    "#%02x%02x%02x" % rgb_prepare(FloatVec [r, g, b]).to_a
  end

  # Converts a hex color string to an rgb array
  def hex_to_rgb (hex : String) : FloatVec
    out = FloatVec.new 0f64

    hex.tr("#", "").each_char.each_slice(2).with_index do |block, idx|
      out[idx] = block.join.to_i(16) / 255.0
    end

    out
  end

  ###

  # Converts an rgb array to an xyz color array.
  def rgb_to_xyz (arr : FloatVec) : FloatVec
    rgbl = arr.map { |val| to_linear(val) }
    out = FloatVec.new 0f64

    # Matrix multiply the rgbl color
    M_INV.each_with_index do |row, idx|
      out[idx] = dot_product(row, rgbl)
    end
    
    out
  end

  def xyz_to_luv (arr) : FloatVec
    x, y, z = arr
    l = f(y)

    return FloatVec[0.0, 0.0, 0.0] if [x, y, z, 0.0].uniq.size == 1 || l == 0.0

    var_u = (4.0 * x) / (x + (15.0 * y) + (3.0 * z))
    var_v = (9.0 * y) / (x + (15.0 * y) + (3.0 * z))
    u = 13.0 * l * (var_u - REF_U)
    v = 13.0 * l * (var_v - REF_V)

    FloatVec[l, u, v]
  end

  def luv_to_lch (arr) : FloatVec
    l, u, v = arr
    c = Math.hypot(u, v)

    if c < 1e-8
      h = 0f64
    else
      hrad = Math.atan2(v, u)
      h = hrad * 180 / Math::PI
      h += 360.0 if h < 0.0
    end

    FloatVec[l, c, h]
  end

  def lch_to_hsluv (arr) : FloatVec
    l, c, h = arr
    return FloatVec [h, 0.0, 100.0] if l > 99.9999999
    return FloatVec [h, 0.0, 0.0] if l < 0.00000001

    mx = max_chroma_for(l, h)
    s = c / mx * 100.0

    FloatVec [h, s, l]
  end

  def lch_to_hpluv (arr) : FloatVec
    l, c, h = arr
    
    return FloatVec [h, 0.0, 100.0] if l > 99.9999999
    return FloatVec [h, 0.0, 0.0] if l < 0.00000001

    mx = max_safe_chroma_for(l)
    s = c / mx * 100.0

    FloatVec [h, s, l]
  end

  ###

  def xyz_to_rgb (arr) : FloatVec
    xyz = M.map { |i| dot_product(i, arr) }
    xyz.map { |i| from_linear(i) }
  end

  def luv_to_xyz (arr) : FloatVec
    l, u, v = arr

    return FloatVec [0.0, 0.0, 0.0] if l == 0

    var_y = f_inv(l)
    var_u = u / (13.0 * l) + REF_U
    var_v = v / (13.0 * l) + REF_V


    y = var_y * REF_Y
    x = 0.0 - (9.0 * y * var_u) / ((var_u - 4.0) * var_v - var_u * var_v)
    z = (9.0 * y - (15.0 * var_v * y) - (var_v * x)) / (3.0 * var_v)

    FloatVec [x, y, z]
  end

  def lch_to_luv (arr) : FloatVec
    l, c, h = arr

    hrad = h / 180f64 * Math::PI
    u = Math.cos(hrad) * c
    v = Math.sin(hrad) * c

    FloatVec [l, u, v]
  end

  def hsluv_to_lch (arr) : FloatVec
    h, s, l = arr

    return FloatVec [100.0, 0.0, h] if l > 99.9999999
    return FloatVec [0.0, 0.0, h] if l < 0.00000001

    mx = max_chroma_for(l, h)
    c = mx / 100.0 * s

    FloatVec [l, c, h]
  end

  def hpluv_to_lch (arr) : FloatVec
    h, s, l = arr

    return FloatVec [100.0, 0.0, h] if l > 99.9999999
    return FloatVec [0.0, 0.0, h] if l < 0.00000001

    mx = max_safe_chroma_for(l)
    c = mx / 100.0 * s

    FloatVec [l, c, h]
  end

  ###

  def max_chroma_for (l, h) : Float64
    hrad = h / 360.0 * Math::PI * 2.0
    lengths = [] of Float64

    get_bounds(l).each do |line|
      l = length_of_ray_until_intersect(hrad, line)
      lengths << l if l
    end

    lengths.min
  end

  def max_safe_chroma_for (l) : Float64
    lengths = [] of Float64

    get_bounds(l).each do |bound|
      m1, b1 = bound
      x = intersect_line_line([m1, b1], [-1.0 / m1, 0.0])
      lengths << distance_from_pole([x, b1 + x * m1])
    end

    lengths.min
  end

  def get_bounds (l) : Array(Array(Float64))
    sub1 = ((l + 16.0) ** 3.0) / 1560896.0
    sub2 = sub1 > EPSILON ? sub1 : l / KAPPA
    ret = [] of Array(Float64)

    M.each do |row|
      m1, m2, m3 = row

      [0, 1].each do |t|
        top1 = (284517.0 * m1 - 94839.0 * m3) * sub2
        top2 = (838422.0 * m3 + 769860.0 * m2 + 731718.0 * m1) * l * sub2 - 769860.0 * t * l
        bottom = (632260.0 * m3 - 126452.0 * m2) * sub2 + 126452.0 * t
        ret << [top1 / bottom, top2 / bottom]
      end
    end

    ret
  end

  def length_of_ray_until_intersect (theta, line)
    m1, b1 = line
    length = b1 / (Math.sin(theta) - m1 * Math.cos(theta))
    return nil if length < 0
    length
  end

  def intersect_line_line (line1, line2) : Float64
    (line1[1] - line2[1]) / (line2[0] - line1[0])
  end

  def distance_from_pole (point) : Float64
    Math.sqrt(point[0] ** 2 + point[1] ** 2)
  end

  def f (t) : Float64
    t > EPSILON ? 116 * ((t / REF_Y) ** (1.0 / 3.0)) - 16.0 : t / REF_Y * KAPPA
  end

  def f_inv (t) : Float64
    t > 8 ? REF_Y * ((t + 16.0) / 116.0) ** 3.0 : REF_Y * t / KAPPA
  end

  def to_linear (c) : Float64
    c > 0.04045 ? ((c + 0.055) / 1.055) ** 2.4 : c / 12.92
  end

  def from_linear (c) : Float64
    c <= 0.0031308 ? 12.92 * c : (1.055 * (c ** (1.0 / 2.4)) - 0.055)
  end

  def dot_product (a, b) : Float64
    a.map_with_index { |_, idx| a[idx] * b[idx] }.sum.to_f64
  end

  # Scales, clamps, and rounds an rgb color array from [0, 1] to [0, 255]
  def rgb_prepare (arr) : StaticArray(Int32, 3)
    out = StaticArray(Int32, 3).new 0

    out.map_with_index do |_, idx|
      (arr[idx].clamp(0, 1).round(3) * 255).round.to_i32
    end
  end
end
