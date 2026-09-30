public import Binary
public import Byte
public import Cardinal
public import Cursor
public import Index
public import Span

extension Span.`Protocol` where Self: ~Copyable & ~Escapable, Element == Byte {

    @inlinable
    public func parse<Output>(
        _ parser: Binary.Machine.Parser<Output>
    ) throws(Binary.Machine.Fault) -> Output {
        try _parsePrefix(parser).value
    }

    @inlinable
    public func parsePrefix<Output>(
        _ parser: Binary.Machine.Parser<Output>
    ) throws(Binary.Machine.Fault) -> (value: Output, count: Index<Byte>.Count) {
        try _parsePrefix(parser)
    }

    @inlinable
    public func parsePrefixUnchecked<Output>(
        _ parser: Binary.Machine.Parser<Output>
    ) throws(Binary.Machine.Fault) -> (value: Output, count: Index<Byte>.Count) {
        try _parsePrefix(parser)
    }

    @inlinable
    public func parseWhole<Output>(
        _ parser: Binary.Machine.Parser<Output>
    ) throws(Binary.Machine.Fault) -> Output {
        let (value, consumed) = try _parsePrefix(parser)

        let total = Index<Byte>.Count(Cardinal(UInt(self.span.count)))
        let remaining = total.subtract.saturating(consumed)
        guard remaining == .zero else {
            throw Binary.Machine.Fault.expectedEnd(remaining: remaining)
        }
        return value
    }
}

extension Span.`Protocol` where Self: ~Copyable & ~Escapable, Element == Byte {

    @inlinable
    package func _parsePrefix<Output>(
        _ parser: Binary.Machine.Parser<Output>
    ) throws(Binary.Machine.Fault) -> (value: Output, count: Index<Byte>.Count) {
        let source = self.span
        var bytes: [Byte] = []
        bytes.reserveCapacity(source.count)
        for index in source.indices {
            bytes.append(source[index])
        }
        var input = bytes[...]
        let value = try parser.parse(&input)
        return (value: value, count: Index<Byte>.Count(Cardinal(UInt(bytes.count - input.count))))
    }
}

extension Binary {

    @inlinable
    public static func withInput<T, E: Swift.Error>(
        _ bytes: [Byte],
        _ body: (inout ArraySlice<Byte>) throws(E) -> T
    ) throws(E) -> T {
        var input = bytes[...]
        return try body(&input)
    }

    @inlinable
    public static func withInput<Bytes, T, E: Swift.Error>(
        _ bytes: Bytes,
        _ body: (inout ArraySlice<Byte>) throws(E) -> T
    ) throws(E) -> T where Bytes: Swift.Collection, Bytes.Element == Byte {
        var input = Array(bytes)[...]
        return try body(&input)
    }

    @inlinable
    public static func withInput<T, E: Swift.Error>(
        _ string: some StringProtocol,
        _ body: (inout ArraySlice<Byte>) throws(E) -> T
    ) throws(E) -> T {
        var input = [Byte](utf8: String(string))[...]
        return try body(&input)
    }
}
