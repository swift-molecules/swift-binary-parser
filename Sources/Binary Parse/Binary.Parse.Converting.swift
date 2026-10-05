public import Binary

extension Binary.Parse {

    public struct Converting<Source, Target>
    where Source: FixedWidthInteger, Target: FixedWidthInteger {

        public let endianness: Binary.Endianness

        @inlinable
        public init(endianness: Binary.Endianness) {
            self.endianness = endianness
        }
    }
}

extension Binary.Parse.Converting {

    public enum Error: Swift.Error {

        case endOfInput(expected: String)

        case overflow(source: Source)
    }
}

extension Binary.Parse.Converting.Error: Sendable where Source: Sendable {}

extension Binary.Parse.Converting: Parsing {
    public var body: Never {
        borrowing get {
            return fatalError("\(Self.self) is a leaf: implement its conformance requirements directly")
        }
    }

    public typealias Input = ArraySlice<Byte>

    public typealias Output = Target

    public typealias Failure = Binary.Parse.Converting<Source, Target>.Error

    @inlinable
    public func parse(_ input: inout Input) throws(Failure) -> Target {
        let sourceSize = MemoryLayout<Source>.size
        guard input.count >= sourceSize else {
            throw .endOfInput(expected: "\(sourceSize) bytes for \(Source.self)")
        }

        let base = input.startIndex
        var sourceValue: Source = 0

        switch endianness {
        case .little:
            (0..<sourceSize).forEach { i in
                let term = Source(truncatingIfNeeded: input[base + i].bitPattern) << (i * 8)
                sourceValue |= term
            }

        case .big:
            (0..<sourceSize).forEach { i in
                let term =
                    Source(truncatingIfNeeded: input[base + i].bitPattern)
                    << ((sourceSize - 1 - i) * 8)
                sourceValue |= term
            }
        }

        input.removeFirst(sourceSize)

        guard let targetValue = Target(exactly: sourceValue) else {
            throw .overflow(source: sourceValue)
        }

        return targetValue
    }
}

extension Binary.Parse.Converting.Error: CustomStringConvertible {

    public var description: String {
        switch self {
        case .endOfInput(let expected):
            return "End of input: expected \(expected)"

        case .overflow(let source):
            return "Value \(source) cannot be represented as \(Target.self)"
        }
    }
}
