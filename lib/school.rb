require "school/version"

module School
  class DSL
    # http://www.ruby-doc.org/core-2.0/Array.html#method-i-pack
    # Opcodes and operands are all the same size, which
    # is determined by the word size for the system.
    WORD_SIZE_CODES = {
      8  => 'C',
      16 => 'S',
      32 => 'L',
      64 => 'Q',
    }

    # https://github.com/tuna-arch/tuna/blob/master/2_isa.md
    INSTRUCTIONS = [
      'mov',
      'add',
      'nand', #
      'shl',
      'shr',
      'jz',
      'lt',
      'gt',   # 0111
      nil,    # 1000
      nil,    # 1001
      nil,    # 1010
      nil,    # 1100
      nil,    # 1101
      'in',   # 1110
      'out',  # 1111
    ]

    attr_reader :word_size
    attr_reader :word_size_bits

    attr_reader :bytecode

    def initialize
      @bytecode = ''
    end

    INSTRUCTIONS.each_with_index do |instruction_name, opcode|
      next if instruction_name.nil?

      # Normal operations. Second argument is direct value.
      define_method(instruction_name) do |*args|
        instruction(0b0000, opcode, *args)
      end

      # Pointer operations. Second argument is an address containing
      # the value.
      define_method(instruction_name + 'p') do |*args|
        instruction(0b0001, opcode, *args)
      end
    end

    (0..7).each do |register|
      define_method("r#{register}") do
        word_size * (register + 2)
      end
    end

    def out
      0x0
    end

    def flags
      0x1 * word_size
    end

    def bits(size)
      @word_size_bits = size
      @word_size = size / 8
    end

    def execute(&block)
      instance_exec(&block)
    end

  private
    def word_size_code
      WORD_SIZE_CODES[word_size_bits]
    end

    def instruction(modifier, opcode, one = 0, two = 0)
      modifier <<= 4 # 0b0001 => 0b00010000

      @bytecode += [(modifier | opcode), one, two].pack(word_size_code + '*')
    end
  end
end
