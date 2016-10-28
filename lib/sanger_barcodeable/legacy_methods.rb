module SangerBarcodeable
  # These methods are all added to maintain compatibility with the
  # Existing sequencescape Barcode API. They will be deprecated over time.
  module LegacyMethods
    # Returns an array of [human_prefix,number,human_checksum]
    # You are encouraged to use the prefix, number and checksum methods instead
    # @deprecated You are encouraged to use the prefix, number and checksum methods instead
    # @param [String] Machine readable barcode
    # @return [Array] array of [machine_prefix:string, number:int, checksum:string]
    def split_barcode(code)
      bc = SangerBarcodeable::SangerBarcode.from_machine(code)
      [bc.prefix.machine_s, bc.number, bc.checksum.machine]
    end

    # Returns an array of [human_prefix,number,human_checksum]
    # @deprecated You are encouraged to create and use a SangerBarcode instead
    # @param [String] Human readable barcode
    # @return [Array] array of [human_prefix:string, number:string, checksum:string]
    def split_human_barcode(code)
      bc = SangerBarcodeable::SangerBarcode.from_human(code)
      [bc.prefix.human, bc.number.to_s, bc.checksum.human]
    end

    # Extracts a barcode number form a machine readable barcoder
    # @deprecated Use SangerBarcodeable::SangerBarcode.from_machine(machine_barcode).number instead
    # @param [String] machine_barcode the machine readable barcode (eg. 4500001234757)
    # @return [String] The barcode number eg. 1234
    def number_to_human(machine_barcode)
      SangerBarcodeable::SangerBarcode.from_machine(machine_barcode).number.to_s
    rescue InvalidBarcode
      # Catching exceptions to preseve old behaviour
      nil
    end

    # Returns the human readable prefix from a machine barcode
    # @deprecated Use SangerBarcodeable::SangerBarcode.from_machine(machine_barcode).prefix.human instead
    # @param [String] machine_barcode the machine readable barcode (eg. 4500001234757)
    # @return [Sting] human readable prefix, eg. 'DN'
    def prefix_from_barcode(machine_barcode)
      SangerBarcodeable::SangerBarcode.from_machine(machine_barcode).prefix.human
    rescue InvalidBarcode
      # Catching exceptions to preseve old behaviour
      nil
    end

    def prefix_to_human(prefix)
      Prefix.from_machine(prefix).human
    end

    def human_to_machine_barcode(human_barcode)
      bc = SangerBarcodeable::SangerBarcode.from_human(human_barcode)
      unless bc.valid?
        raise InvalidBarcode, 'The human readable barcode was invalid, perhaps it was mistyped?'
      end
      bc.machine_barcode
    end

    def barcode_to_human(code)
      SangerBarcodeable::SangerBarcode.from_machine(code).human_barcode
    rescue InvalidBarcode
      # Catching exceptions to preseve old behaviour
      nil
    end

    # We disable the SnakeCase check here as this method is intended to support
    # legacy code.
    def check_EAN(code) # rubocop:disable Style/MethodName
      SangerBarcodeable::SangerBarcode.from_machine(code).check_ean
    end

    # Returns the Human barcode or raises an InvalidBarcode exception if there is a problem.  The barcode is
    # considered invalid if it does not translate to a Human barcode or, when the optional +prefix+ is specified,
    # its human equivalent does not match.
    def barcode_to_human!(code, prefix = nil)
      (barcode = SangerBarcodeable::SangerBarcode.from_machine(code)) ||
        raise(InvalidBarcode, "Barcode #{code} appears to be invalid")
      unless prefix.nil? || (barcode.prefix.human == prefix)
        raise InvalidBarcode, "Barcode #{code} (#{barcode.human_barcode}) does not match prefix #{prefix}"
      end
      barcode.human_barcode
    end

    def calculate_barcode(human_prefix, number)
      SangerBarcode.new(prefix: human_prefix, number: number).machine_barcode
    end

    def calculate_checksum(human_prefix, number)
      SangerBarcode.new(prefix: human_prefix, number: number).checksum.human
    end
  end
end
