# SBCF

[![Yard Docs](http://img.shields.io/badge/yard-docs-blue.svg)](https://www.rubydoc.info/github/sanger/sanger_barcode_format)
![Ruby](https://github.com/JamesGlover/sanger_barcode_format/workflows/Ruby/badge.svg)

:warning: This is an early version and may be unstable.

Barcodes generated by Sequencescape and other applications have two
representations, a human readable form, and an ean13 representation. The ean13
is regularly used to generate physical barcodes, and is returned by the various
barcode scanners. Meanwhile the human readable form is often used when items
are searched for manually, particularly when there is no physical access to the
item itself.

Barcodes are comprised of three components:

- A prefix: represented by two uppercase letters in the human readable form,
  and encoded as three digits in the ean13. Please be aware that some encoded
  prefixes begin with zero, which can get stripped under some circumstances.
  Prefixes generally identify the type of item which has received the barcode
  and are registered in an external database.
- A number: A number between 0 and 9999999 inclusive. The human form is not
  typically zero padded.
- A checksum: In addition to the ean13 of the machine printed version,
  barcodes also contain a single character / two digit internal checksum used to
  identify input errors of the human readable form.

In addition, printed forms will contain the standard EAN checksum digit. This
checksum is included in the output of this gem and does not need to be
recalculated .

## Installation

Add this line to your application's Gemfile:

    gem 'sanger_barcode_format'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sanger_barcode_format

## Usage

```ruby
  # Using builders
  barcode = SBCF::SangerBarcode.from_human('DN12345R')
  barcode = SBCF::SangerBarcode.from_machine(4500101234757)
  barcode = SBCF::SangerBarcode.from_prefix_and_number('EG',123)

  # Using standard initialize
  barcode = SBCF::SangerBarcode.new(prefix:'EG',number:123)
  barcode = SBCF::SangerBarcode.new(human_barcode:'DN12345R')
  barcode = SBCF::SangerBarcode.new(hmachine_barcode:4500101234757)

  # Converting between formats
  barcode = SBCF::SangerBarcode.new(prefix:'PR',number:1234)
  barcode.human_barcode # => PR1234K'
  barcode.machine_barcode # => 4500001234757

  # Pulling out components
  barcode = SBCF::SangerBarcode.new(machine_barcode: 4500001234757)
  barcode.prefix.human # => 'PR'
  barcode.checksum.human # => 'K'
```

## LegacyMethods

A number of legacy method are provided in the module
SBCF::LegacyMethods. These are used to allow near drop-in
replacement of the barcode component of Sequencescape. They should NOT be used
for new applications. Legacy methods should be required explicitly, and can
be used to extend existing interfaces.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
