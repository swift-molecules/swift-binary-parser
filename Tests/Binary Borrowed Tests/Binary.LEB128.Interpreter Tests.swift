import Binary_Parser_Test_Support
import Byte
import Span
import Testing

@testable import Binary_Parser

@Suite("Binary.LEB128 Interpreter")
struct BinaryLEB128InterpreterTests {
    @Suite struct Prefix {}
    @Suite struct Whole {}
}

extension BinaryLEB128InterpreterTests.Prefix {

    @Test
    func `uleb128 decodes known sequences`() throws {
        let known: [([UInt8], UInt64)] = [([0x00], 0), ([0x7F], 127), ([0x80, 0x01], 128), ([0xE5, 0x8E, 0x26], 624485)]
        for (encoded, expected) in known {
            let bytes = encoded.map(Byte.init(bitPattern:))
            let value = try bytes.span.parse(Binary.Machine.uleb128Parser())
            #expect(value == expected)
        }
    }

    @Test
    func `sleb128 decodes known sequences`() throws {
        let known: [([UInt8], Int64)] = [([0x00], 0), ([0x7F], -1), ([0x80, 0x7F], -128)]
        for (encoded, expected) in known {
            let bytes = encoded.map(Byte.init(bitPattern:))
            let value = try bytes.span.parse(Binary.Machine.sleb128Parser())
            #expect(value == expected)
        }
    }

    @Test
    func `uleb128 round-trips with the encoder`() throws {
        for v in [0, 1, 624485, UInt64.max] as [UInt64] {
            let encoded = [Byte](leb128: v)
            let value = try encoded.span.parse(Binary.Machine.uleb128Parser())
            #expect(value == v)
        }
    }

    @Test
    func `sleb128 round-trips with the encoder`() throws {
        for v in [0, 1, -1, -624485, Int64.min, Int64.max] as [Int64] {
            let encoded = [Byte](leb128: v)
            let value = try encoded.span.parse(Binary.Machine.sleb128Parser())
            #expect(value == v)
        }
    }

    @Test
    func `uleb128 over-long encoding faults`() {

        let overLong = [Byte](repeating: Byte(bitPattern: 0x80), count: 10) + [Byte(bitPattern: 0x01)]
        do throws(Binary.Machine.Fault) {
            _ = try overLong.span.parse(Binary.Machine.uleb128Parser())
            Issue.record("expected Binary.Machine.Fault")
        } catch {

        }
    }

    @Test
    func `uleb128 unterminated faults`() {
        let bytes: [Byte] = ([0x80, 0x80] as [UInt8]).map(Byte.init(bitPattern:))
        do throws(Binary.Machine.Fault) {
            _ = try bytes.span.parse(Binary.Machine.uleb128Parser())
            Issue.record("expected Binary.Machine.Fault")
        } catch {

        }
    }
}

extension BinaryLEB128InterpreterTests.Whole {

    @Test
    func `uleb128 decodes via parseWhole`() throws {
        let encoded = ([0xE5, 0x8E, 0x26] as [UInt8]).map(Byte.init(bitPattern:))
        let value = try encoded.span.parseWhole(Binary.Machine.uleb128Parser())
        #expect(value == 624485)
    }

    @Test
    func `sleb128 decodes via parseWhole`() throws {
        let encoded = ([0x80, 0x7F] as [UInt8]).map(Byte.init(bitPattern:))
        let value = try encoded.span.parseWhole(Binary.Machine.sleb128Parser())
        #expect(value == -128)
    }

    @Test
    func `uleb128 round-trips via parseWhole`() throws {
        for u in [0, 1, 624485, UInt64.max] as [UInt64] {
            let encoded = [Byte](leb128: u)
            let value = try encoded.span.parseWhole(Binary.Machine.uleb128Parser())
            #expect(value == u)
        }
    }

    @Test
    func `sleb128 round-trips via parseWhole`() throws {
        for s in [0, 1, -1, -624485, Int64.min, Int64.max] as [Int64] {
            let encoded = [Byte](leb128: s)
            let value = try encoded.span.parseWhole(Binary.Machine.sleb128Parser())
            #expect(value == s)
        }
    }
}
