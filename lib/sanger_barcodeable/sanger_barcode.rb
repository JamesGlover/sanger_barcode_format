require 'sanger_barcodeable/builders'

module SangerBarcodeable
  class SangerBarcode

    attr_reader :prefix, :number, :checksum

    extend Builders

    # Returns the machine readable ean13
    #
    # @return [Int] The machine readable ean13 barcode
    def machine_barcode
      @machine_barcode ||= calculate_machine_barcode
    end

    # Returns the human readable leter-number combination
    #
    # @return [String] eg. DN12345R
    def human_barcode
      @human_barcode ||= calculate_human_barcode
    end

    # Returns the internally used checksum
    #
    # @return [SangerBarcodeable::Checksum] The internally used checksum
    def checksum
      @checksum ||= Checksum.from_human(calculate_checksum)
    end

    # Create a new barcode object.
    # Either:
    # - Provide a prefix and number
    # - Provide a machine barcode (Ean13)
    # - Provide a human readable barcode (Eg. DN12345) If checksum required is set to true will raise ChecksumRequired
    #   if the internal checksum character is missing.
    #
    # @param [String||SangerBarcodable::Prefix] prefix:nil The two letter prefix or a Prefix object
    # @param [Int] number:nil The unique number, up to 7 digits long
    # @param [String] checksum:nil Optional human readable checksum character.
    # @param [Sting||Int] machine_barcode:nil Ean13 barcode as red by a scanner
    # @param [String] human_barcode:nil Human readable barcode eg. DN12345R
    # @param [Bool] checksum_required:false If set to true will enforce presence of checksum on human_barcode input
    # @return [SangerBarcodable::SangerBarcode] A representation of the barcode
    def initialize(prefix:nil, number:nil, checksum:nil, machine_barcode:nil, human_barcode:nil, checksum_required:false)
      raise ArgumentError, "You must provide either a prefix and a number, or a human or machine barcode" unless [(prefix&&number),machine_barcode,human_barcode].one?

      if prefix && number
        @prefix = prefix.is_a?(Prefix) ? prefix : Prefix.from_human(prefix)
        @number = number.to_i
        @checksum = Checksum.from_human(checksum) if checksum
      elsif machine_barcode
        self.machine_barcode = machine_barcode.to_i
      elsif human_barcode
        @checksum_required = checksum_required
        self.human_barcode = human_barcode
      else
        # We shouldn't get here, as the argument validation above ensures one and only
        # one condition is valid.
        raise StandardError, 'Unexpected state.'
      end
    end

    def valid?
      number.to_s.size <= NUMBER_LENGTH &&
      calculate_checksum == checksum.human &&
      check_EAN
    end

    def check_EAN
      #the EAN checksum is calculated so that the EAN of the code with checksum added is 0
      #except the new column (the checksum) start with a different weight (so the previous column keep the same weight)
      return true if @machine_barcode.nil?
      calculate_EAN(@machine_barcode, 1) == 0
    end

    # Legacy method
    # Returns an array of strings
    # [human_prefix,number,human_checksum]
    def split_human_barcode
      [prefix.human,number.to_s,checksum.human]
    end

    # Legacy method
    # Returns an array
    # [machine_prefix(string),number(int),machine_checksum(string)]
    def split_barcode
      [prefix.machine_s,number,checksum.machine]
    end

    ####### PRIVATE METHODS ###################################################################
    private

    # Used internally during barcode creation. Takes a machine barcode and
    # splits it into is component parts
    #
    # @param [String||Int] The 13 digit long ean13 barcode
    # @return [String||Int] Returns the input
    def machine_barcode=(machine_barcode)
      @machine_barcode = machine_barcode.to_i
      match = MachineBarcodeFormat.match(machine_barcode.to_s)
      raise InvalidBarcode, "#{machine_barcode} is not a valid ean13 barcode" if match.nil?
      set_from_machine_components(*match)
      machine_barcode
    end

    def set_from_machine_components(_full, prefix, number, _checksum, _check)
      @prefix = Prefix.from_machine(prefix)
      @number = number.to_i
    end

    def human_barcode=(human_barcode)
      match = HumanBarcodeFormat.match(human_barcode)
      raise InvalidBarcode, "The human readable barcode was invalid, perhaps it was mistyped?" if match.nil?
      human_prefix = match[1]
      short_barcode = match[2]
      checksum = match[3]
      raise ChecksumRequired, "You must supply a complete barcode, including the final letter (eg. DN12345R)." if @checksum_required && checksum.nil?
      @prefix = Prefix.from_human(human_prefix)
      @number = short_barcode.to_i
      @checksum = Checksum.from_human(checksum) if checksum
    end

    def calculate_EAN13(code)
      calculate_EAN(code)
    end

    def calculate_EAN(code, initial_weight=3)
      #The EAN is calculated by adding each digit modulo 10 ten weighted by 1 or 3 ( in seq)
      ean = 0
      weight = initial_weight
      while code > 0
        code, c = code.divmod 10
        ean += c*weight % 10
        weight = weight == 1 ? 3 : 1
      end
      (10 - ean) % 10
    end

    def calculate_checksum
      string = prefix.human + number.to_s
      list = string.reverse
      sum = 0
      list.bytes.each_with_index do |byte,i|
        sum += byte * (i+1)
      end
      (sum % 23 + CHECKSUM_ASCII_OFFSET).chr
    end

    # Returns the full length machine barcode
    def calculate_machine_barcode
      sanger_barcode*10+calculate_EAN13(sanger_barcode)
    end

    def calculate_human_barcode
      "#{prefix.human}#{number}#{checksum.human}" if valid?
    end

    # Returns the machine barcode minus the EAN13 print checksum.
    def sanger_barcode
      raise ArgumentError, "Number : #{number} to big to generate a barcode." if number.to_s.size > 7
      prefix.machine_full + (number * 100) + calculate_checksum.getbyte(0)
    end

  end
end
