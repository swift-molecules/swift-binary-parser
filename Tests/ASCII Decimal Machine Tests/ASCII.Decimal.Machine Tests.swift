import ASCII_Decimal_Machine
import Testing

@Suite struct `ASCII Decimal Machine Tests` {
    @Test(arguments: ["0", "00", "0000000000000000000000000000000", "255", "00000000000000000000000255"])
    func unsignedBoundariesAndLeadingZeros(_ text: String) throws {
        let parser = Binary.Parser.machine(ASCII.Decimal.Machine.unsigned(UInt8.self))
        #expect(try parser.parseWhole([Byte](utf8: text)) == UInt8(text))
    }

    @Test(arguments: ["256", "999", "1000", "00000000000000000000256"])
    func unsignedOverflowIsNotAValidShorterPrefix(_ text: String) {
        let parser = Binary.Parser.machine(ASCII.Decimal.Machine.unsigned(UInt8.self))
        var input = [Byte](utf8: text + ",tail")[...]
        #expect(throws: Binary.Machine.Fault.outOfRange) { try parser.parsePrefix(&input) }
        #expect(input.map(\.bitPattern) == Array(",tail".utf8))
    }

    @Test(arguments: ["-128", "127", "+127", "-0", "+0", "-00000000000000000128"])
    func signedBoundaries(_ text: String) throws {
        let parser = Binary.Parser.machine(ASCII.Decimal.Machine.signed(Int8.self))
        #expect(try parser.parseWhole([Byte](utf8: text)) == Int8(text))
    }

    @Test(arguments: ["128", "+128", "-129", "256", "-256", "999999999999999999999999"])
    func signedOverflow(_ text: String) {
        let parser = Binary.Parser.machine(ASCII.Decimal.Machine.signed(Int8.self))
        #expect(throws: Binary.Machine.Fault.outOfRange) {
            try parser.parseWhole([Byte](utf8: text))
        }
    }

    @Test func fullWidthLimits() throws {
        let unsigned = Binary.Parser.machine(ASCII.Decimal.Machine.unsigned(UInt64.self))
        let signed = Binary.Parser.machine(ASCII.Decimal.Machine.signed(Int64.self))
        #expect(try unsigned.parseWhole([Byte](utf8: String(UInt64.max))) == UInt64.max)
        #expect(try signed.parseWhole([Byte](utf8: String(Int64.min))) == Int64.min)
        #expect(try signed.parseWhole([Byte](utf8: String(Int64.max))) == Int64.max)
    }

    @Test func fullWidth128BitLimitsAndOverflow() throws {
        let unsigned = Binary.Parser.machine(ASCII.Decimal.Machine.unsigned(UInt128.self))
        let signed = Binary.Parser.machine(ASCII.Decimal.Machine.signed(Int128.self))
        #expect(try unsigned.parseWhole([Byte](utf8: String(UInt128.max))) == UInt128.max)
        #expect(try signed.parseWhole([Byte](utf8: String(Int128.min))) == Int128.min)
        #expect(try signed.parseWhole([Byte](utf8: String(Int128.max))) == Int128.max)
        #expect(throws: Binary.Machine.Fault.outOfRange) {
            try unsigned.parseWhole([Byte](utf8: String(UInt128.max) + "0"))
        }
        #expect(throws: Binary.Machine.Fault.outOfRange) {
            try signed.parseWhole([Byte](utf8: String(Int128.min) + "0"))
        }
    }

    @Test func prefixLeavesDelimiterFromNonzeroSlice() throws {
        let parser = Binary.Parser.machine(ASCII.Decimal.Machine.signed(Int8.self))
        var input = [Byte](utf8: "xx-128,tail").dropFirst(2)
        #expect(try parser.parsePrefix(&input) == -128)
        #expect(input.map(\.bitPattern) == Array(",tail".utf8))
        #expect(input.startIndex == 6)
    }

    @Test(arguments: ["", "+", "-", "x", "--1", "+-1"])
    func signedRequiresDigits(_ text: String) {
        let parser = Binary.Parser.machine(ASCII.Decimal.Machine.signed(Int8.self))
        #expect(throws: Binary.Machine.Fault.self) { try parser.parseWhole([Byte](utf8: text)) }
    }

    @Test func unsignedRejectsSignAndWholeRequiresEnd() {
        let parser = Binary.Parser.machine(ASCII.Decimal.Machine.unsigned(UInt8.self))
        #expect(throws: Binary.Machine.Fault.predicateFailed(byte: Byte(bitPattern: 0x2B))) {
            try parser.parseWhole([Byte](utf8: "+1"))
        }
        #expect(throws: Binary.Machine.Fault.self) {
            try parser.parseWhole([Byte](utf8: "1,tail"))
        }
    }
}
