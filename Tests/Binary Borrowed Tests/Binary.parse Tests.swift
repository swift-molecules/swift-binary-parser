import Binary_Parser_Test_Support
import Byte
import Index
import Span
import Testing

@testable import Binary_Parser

extension Binary {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct `Edge Case` {}
    }
}

extension Binary.Test.Unit {

    @Test
    func `byte-span parse u8 returns first byte`() throws {
        let encoded = ([0x42, 0x99] as [UInt8]).map(Byte.init(bitPattern:))
        let value = try encoded.span.parse(Binary.Machine.u8Parser())
        #expect(value == 0x42)
    }

    @Test
    func `byte-span parse u16le decodes little-endian`() throws {
        let encoded = ([0x34, 0x12] as [UInt8]).map(Byte.init(bitPattern:))
        let value = try encoded.span.parse(Binary.Machine.u16leParser())
        #expect(value == 0x1234)
    }

    @Test
    func `byte-span parse u16be decodes big-endian`() throws {
        let encoded = ([0x12, 0x34] as [UInt8]).map(Byte.init(bitPattern:))
        let value = try encoded.span.parse(Binary.Machine.u16beParser())
        #expect(value == 0x1234)
    }

    @Test
    func `byte-span parse u32le decodes little-endian`() throws {
        let encoded = ([0x78, 0x56, 0x34, 0x12] as [UInt8]).map(Byte.init(bitPattern:))
        let value = try encoded.span.parse(
            Binary.Machine.u32leParser()
        )
        #expect(value == 0x1234_5678)
    }

    @Test
    func `byte-span parse u32be decodes big-endian`() throws {
        let encoded = ([0x12, 0x34, 0x56, 0x78] as [UInt8]).map(Byte.init(bitPattern:))
        let value = try encoded.span.parse(
            Binary.Machine.u32beParser()
        )
        #expect(value == 0x1234_5678)
    }

    @Test
    func `byte-span parse u64be decodes big-endian`() throws {
        let encoded = ([0x01, 0x23, 0x45, 0x67, 0x89, 0xAB, 0xCD, 0xEF] as [UInt8]).map(Byte.init(bitPattern:))
        let value = try encoded.span.parse(
            Binary.Machine.u64beParser()
        )
        #expect(value == 0x0123_4567_89AB_CDEF)
    }

    @Test
    func `byte-span parsePrefix u8 returns value and consumed count 1`() throws {
        let encoded = ([0x42, 0x99] as [UInt8]).map(Byte.init(bitPattern:))
        let result = try encoded.span.parsePrefix(Binary.Machine.u8Parser())
        #expect(result.value == 0x42)
        #expect(result.count == Index<Byte>.Count(Cardinal.one))
    }

    @Test
    func `byte-span parsePrefix u16le returns value and consumed count 2`() throws {
        let encoded = ([0x34, 0x12, 0xAA, 0xBB] as [UInt8]).map(Byte.init(bitPattern:))
        let result = try encoded.span.parsePrefix(
            Binary.Machine.u16leParser()
        )
        #expect(result.value == 0x1234)
        #expect(result.count == Index<Byte>.Count(Cardinal(2)))
    }

    @Test
    func `byte-span parsePrefix u32le returns value and consumed count 4`() throws {
        let encoded = ([0x78, 0x56, 0x34, 0x12, 0xAA, 0xBB] as [UInt8]).map(Byte.init(bitPattern:))
        let result = try encoded.span.parsePrefix(
            Binary.Machine.u32leParser()
        )
        #expect(result.value == 0x1234_5678)
        #expect(result.count == Index<Byte>.Count(Cardinal(4)))
    }

    @Test
    func `byte-span parsePrefixUnchecked u8 returns value and consumed count 1`() throws {
        let encoded = ([0x42, 0x99] as [UInt8]).map(Byte.init(bitPattern:))
        let result = try encoded.span.parsePrefixUnchecked(
            Binary.Machine.u8Parser()
        )
        #expect(result.value == 0x42)
        #expect(result.count == Index<Byte>.Count(Cardinal.one))
    }

    @Test
    func `byte-span parseWhole u8 succeeds when input is exactly 1 byte`() throws {
        let encoded = ([0x42] as [UInt8]).map(Byte.init(bitPattern:))
        let value = try encoded.span.parseWhole(Binary.Machine.u8Parser())
        #expect(value == 0x42)
    }

    @Test
    func `byte-span parseWhole u16le succeeds when input is exactly 2 bytes`() throws {
        let encoded = ([0x34, 0x12] as [UInt8]).map(Byte.init(bitPattern:))
        let value = try encoded.span.parseWhole(Binary.Machine.u16leParser())
        #expect(value == 0x1234)
    }

    @Test
    func `byte-span parseWhole u32be succeeds at exact-length input`() throws {
        let encoded = ([0x12, 0x34, 0x56, 0x78] as [UInt8]).map(Byte.init(bitPattern:))
        let value = try encoded.span.parseWhole(
            Binary.Machine.u32beParser()
        )
        #expect(value == 0x1234_5678)
    }

    @Test
    func `byte-span parseWhole throws expectedEnd when bytes remain`() {

        let bytes: [Byte] = ([0x42, 0x99] as [UInt8]).map(Byte.init(bitPattern:))
        do throws(Binary.Machine.Fault) {
            _ = try bytes.span.parseWhole(Binary.Machine.u8Parser())
            Issue.record("expected Binary.Machine.Fault.expectedEnd")
        } catch {

        }
    }
}

extension Binary.Test.`Edge Case` {

    @Test
    func `byte-span parse throws insufficientBytes when input shorter than needed`() {
        let bytes: [Byte] = ([0x42] as [UInt8]).map(Byte.init(bitPattern:))
        do throws(Binary.Machine.Fault) {
            _ = try bytes.span.parse(Binary.Machine.u32leParser())
            Issue.record("expected Binary.Machine.Fault")
        } catch {

        }
    }

    @Test
    func `byte-span parse on empty input throws insufficientBytes`() {
        let bytes: [Byte] = []
        do throws(Binary.Machine.Fault) {
            _ = try bytes.span.parse(Binary.Machine.u8Parser())
            Issue.record("expected Binary.Machine.Fault")
        } catch {

        }
    }

    @Test
    func `byte-span parse of single-byte input returns the byte`() throws {
        let encoded = ([0xAB] as [UInt8]).map(Byte.init(bitPattern:))
        let value = try encoded.span.parse(Binary.Machine.u8Parser())
        #expect(value == 0xAB)
    }
}

extension Binary.Test.Unit {

    @Test
    func `Binary.withInput from byte array hands the body a byte slice`() {
        var observedCount = 0
        Binary.withInput(([0x01, 0x02, 0x03] as [UInt8]).map(Byte.init(bitPattern:))) { (input: inout ArraySlice<Byte>) in
            observedCount = input.count
        }
        #expect(observedCount == 3)
    }

    @Test
    func `Binary.withInput from ArraySlice hands the body a byte slice`() {
        let bytes: [Byte] = ([0x01, 0x02, 0x03, 0x04, 0x05] as [UInt8]).map(Byte.init(bitPattern:))
        var observedCount = 0
        Binary.withInput(bytes[1..<4]) { (input: inout ArraySlice<Byte>) in
            observedCount = input.count
        }
        #expect(observedCount == 3)
    }

    @Test
    func `Binary.withInput from string produces input with correct UTF-8 count`() {
        var observedCount = 0
        Binary.withInput("ABC") { (input: inout ArraySlice<Byte>) in
            observedCount = input.count
        }
        #expect(observedCount == 3)
    }
}
