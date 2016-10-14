require 'spec_helper'

describe School do
  context School::DSL do
    it 'generates the correct bytecode' do
      dsl = School::DSL.new
      dsl.execute {
        bits 16

        mov 0x2, r0
        addp out, r0
      }

      expected = [
        0b0000_0000, # No modifier, mov instruction.
        0x2,         # First argument.
        0x4,         # r1 = (2 byte word_size) * 0x2.
        0b0001_0001, # Pointer modifier, add instruction.
        0x0,         # OUT register.
        0x4,         # r1 = (2 byte word_size) * 0x2.
      ].pack('S>*')

      expect(dsl.bytecode).to eq(expected)
    end
  end
end
