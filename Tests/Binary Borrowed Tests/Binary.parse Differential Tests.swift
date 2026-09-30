import Binary_Parser_Test_Support
import Byte
import Span
import Testing

@testable import Binary_Parser

private func bytes(_ values: UInt8...) -> [Byte] {
    values.map(Byte.init(bitPattern:))
}

private func alternatives() -> Binary.Machine.Parser<[Byte]> {
    Binary.Machine.build { builder in
        Binary.Machine.oneOf(
            [
                Binary.Machine.bytes(bytes(0x01, 0x02), in: &builder),
                Binary.Machine.bytes(bytes(0x01), in: &builder),
            ],
            in: &builder
        )
    }
}

private struct Outcome: Equatable {
    let result: Result<[Byte], Binary.Machine.Fault>
    let consumed: Int
}

private func borrowed(_ encoded: [Byte]) -> Outcome {
    do throws(Binary.Machine.Fault) {
        let prefix = try encoded.span.parsePrefix(alternatives())
        return Outcome(result: .success(prefix.value), consumed: Int(bitPattern: prefix.count.cardinal.rawValue))
    } catch {
        return Outcome(result: .failure(error), consumed: 0)
    }
}

private func sliced(_ encoded: [Byte]) -> Outcome {
    var input = encoded[...]
    do throws(Binary.Machine.Fault) {
        let value = try alternatives().parse(&input)
        return Outcome(result: .success(value), consumed: encoded.count - input.count)
    } catch {
        return Outcome(result: .failure(error), consumed: 0)
    }
}

@Suite
struct `Binary.parse Differential Tests` {

    @Test(arguments: [
        bytes(0x01, 0x02),
        bytes(0x01, 0x02, 0x03),
        bytes(0x01, 0x03),
        bytes(0x01),
        bytes(0x02),
        bytes(),
    ])
    func `span entry points agree with the slice runner`(_ encoded: [Byte]) {
        #expect(borrowed(encoded) == sliced(encoded))
    }

    @Test
    func `a failed alternative rolls back before the next one`() {
        #expect(borrowed(bytes(0x01, 0x03)) == Outcome(result: .success(bytes(0x01)), consumed: 1))
    }

    @Test
    func `the output outlives the source span`() throws {
        func parsed() throws(Binary.Machine.Fault) -> [Byte] {
            let encoded = bytes(0x01, 0x02, 0x09)
            return try encoded.span.parse(alternatives())
        }
        #expect(try parsed() == bytes(0x01, 0x02))
    }
}
