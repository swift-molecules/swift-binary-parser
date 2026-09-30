import Binary_Parser_Test_Support
import Byte
import Span
import Testing

@testable import Binary_Parser

private func bytes(_ values: UInt8...) -> [Byte] {
    values.map(Byte.init(bitPattern:))
}

private func fault(_ body: () throws(Binary.Machine.Fault) -> Void) -> Binary.Machine.Fault? {
    do throws(Binary.Machine.Fault) {
        try body()
        return nil
    } catch {
        return error
    }
}

@Suite
struct `Binary.parse Boundary Tests` {

    @Test
    func `a success that consumes nothing reports a zero count`() throws {
        let parser = Binary.Machine.build { builder in
            Binary.Machine.optional(Binary.Machine.byte(Byte(bitPattern: 0x7F), in: &builder), in: &builder)
        }
        let encoded = bytes(0x01)
        let prefix = try encoded.span.parsePrefix(parser)
        #expect(prefix.value == nil)
        #expect(prefix.count == .zero)
    }

    @Test
    func `a span that starts at a nonzero offset counts from its own start`() throws {
        let encoded = bytes(0xAA, 0xBB, 0x34, 0x12, 0xCC)
        let tail = encoded[2...]
        let prefix = try tail.span.parsePrefix(Binary.Machine.u16leParser())
        #expect(prefix.value == 0x1234)
        #expect(prefix.count == 2)
    }

    @Test
    func `optional rolls back a partially matched child`() throws {
        let parser = Binary.Machine.build { builder in
            Binary.Machine.sequence(
                Binary.Machine.optional(Binary.Machine.bytes(bytes(0x01, 0x02), in: &builder), in: &builder),
                Binary.Machine.take1(in: &builder),
                combine: { first, second in first == nil && second == Byte(bitPattern: 0x01) },
                in: &builder
            )
        }
        let encoded = bytes(0x01, 0x03)
        let prefix = try encoded.span.parsePrefix(parser)
        #expect(prefix.value)
        #expect(prefix.count == 1)
    }

    @Test
    func `many keeps the complete elements and rolls back the partial one`() throws {
        let parser = Binary.Machine.build { builder in
            Binary.Machine.many(Binary.Machine.bytes(bytes(0x01, 0x02), in: &builder), in: &builder)
        }
        let encoded = bytes(0x01, 0x02, 0x01, 0x02, 0x01, 0x09)
        let prefix = try encoded.span.parsePrefix(parser)
        #expect(prefix.value == [bytes(0x01, 0x02), bytes(0x01, 0x02)])
        #expect(prefix.count == 4)
    }

    @Test
    func `fold keeps the accumulated value and rolls back the partial element`() throws {
        let parser = Binary.Machine.build { builder in
            Binary.Machine.fold(
                Binary.Machine.u16le(in: &builder),
                initial: 0,
                combine: { total, next in total + Int(next) },
                in: &builder
            )
        }
        let encoded = bytes(0x01, 0x00, 0x02, 0x00, 0x03)
        let prefix = try encoded.span.parsePrefix(parser)
        #expect(prefix.value == 3)
        #expect(prefix.count == 4)
    }

    @Test
    func `a failing tryMap surfaces its own fault`() {
        let parser = Binary.Machine.build { builder in
            Binary.Machine.take1(in: &builder).tryMap(
                { byte throws(Binary.Machine.Fault) -> Byte in
                    guard byte != Byte(bitPattern: 0x00) else { throw .malformed }
                    return byte
                },
                in: &builder
            )
        }
        let encoded = bytes(0x00)
        #expect(fault { () throws(Binary.Machine.Fault) in _ = try encoded.span.parse(parser) } == .malformed)
    }

    @Test
    func `recursion past the depth limit faults with that limit`() {
        let parser: Binary.Machine.Parser<Int> = Binary.Machine.recursive(maxDepth: 3) { builder, nested in
            Binary.Machine.sequence(
                Binary.Machine.byte(Byte(bitPattern: 0x28), in: &builder),
                nested.expression(in: &builder),
                combine: { (_: Byte, inner: Int) in inner },
                in: &builder
            )
        }
        let encoded = [Byte](repeating: Byte(bitPattern: 0x28), count: 10)
        #expect(fault { () throws(Binary.Machine.Fault) in _ = try encoded.span.parse(parser) } == .depthExceeded(limit: 3))
    }

    @Test
    func `whole-input parsing reports the exact remainder`() {
        let encoded = bytes(0x42, 0x99, 0x98)
        #expect(fault { () throws(Binary.Machine.Fault) in _ = try encoded.span.parseWhole(Binary.Machine.u8Parser()) } == .expectedEnd(remaining: 2))
    }

    @Test
    func `truncated input reports what was needed and what was there`() {
        let encoded = bytes(0x42)
        #expect(fault { () throws(Binary.Machine.Fault) in _ = try encoded.span.parse(Binary.Machine.u32leParser()) } == .insufficientBytes(need: 4, have: 1))
    }

    @Test
    func `an unterminated LEB128 runs out of bytes`() {
        let encoded = bytes(0x80, 0x80)
        #expect(fault { () throws(Binary.Machine.Fault) in _ = try encoded.span.parse(Binary.Machine.uleb128Parser()) } == .insufficientBytes(need: 1, have: 0))
    }

    @Test
    func `an over-long LEB128 overflows`() {
        let encoded = [Byte](repeating: Byte(bitPattern: 0x80), count: 10) + bytes(0x01)
        #expect(fault { () throws(Binary.Machine.Fault) in _ = try encoded.span.parse(Binary.Machine.uleb128Parser()) } == .leb128Overflow)
    }
}
