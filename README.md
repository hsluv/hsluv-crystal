# hsluv-crystal
[![Build Status](https://travis-ci.org/shinzlet/hsluv-crystal.svg?branch=master)](https://travis-ci.org/shinzlet/hsluv-crystal)

An implementation of the [HSLuv](https://www.hsluv.org/) colorspace written in
crystal. Adapted from [hsluv-ruby](https://github.com/hsluv/hsluv-ruby).

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     hsluv:
       github: shinzlet/hsluv-crystal
   ```

2. Run `shards install`

## Usage

```crystal
require "hsluv"
```

## Usage

- `hue` is a Float64 between 0 and 360
- `saturation` is a Float64 between 0 and 100
- `lightness` is a Float64 between 0 and 100
- `hex` is the hexadecimal format of the color
- `red` is a Float64 between 0 and 1
- `green` is a Float64 between 0 and 1
- `blue` is a Float64 between 0 and 1

#### HSLuv::hsluv_to_hex(hue, saturation, lightness) -> color as a hex string

```
HSLuv.hsluv_to_hex(12.177, 100, 53.23)
=> #ff0000
```

#### HSLuv::hsluv_to_rgb(hue, saturation, lightness) -> color as rgb

```
HSLuv.hsluv_to_rgb(12.177, 100, 53.23)
=> StaticArray[0.9998643703868711, 6.849859221502719e-14, 8.791283550555612e-06]
```

#### HSLuv::hex_to_hsluv(hex) -> list of floats as defined above

```
HSLuv.hex_to_hsluv("#ff0000")
=> StaticArray[12.177050630061776, 100.0000000000022, 53.23711559542933]
```

#### HSLuv::rgb_to_hsluv(rgb) -> list of floats as defined above

```
HSLuv.rgb_to_hsluv(0.99, 6.84e-14, 8.79e-16)
=> StaticArray[12.17705063006216, 100.00000000000209, 52.711595266911985]
```

For HPLuv (the pastel variant), use:

  - `hpluv_to_hex`
  - `hpluv_to_rgb`
  - `hex_to_hpluv`
  - `rgb_to_hpluv`

## Testing

1. Run `crystal spec` in the project directory

## Contributing

1. Fork it (<https://github.com/shinzlet/hsluv-crystal/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors
- [Seth Hinz](https://github.com/your-github-user) - port author, maintainer
