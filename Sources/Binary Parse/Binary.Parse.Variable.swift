public import Binary

extension Binary.Parse {

    public struct Variable<T: FixedWidthInteger> {

        public let count: Int

        public let endianness: Binary.Endianness

        @inlinable
        public init(count: Int, endianness: Binary.Endianness) {
            precondition(
                count > 0 && count <= MemoryLayout<T>.size,
                "count must be between 1 and \(MemoryLayout<T>.size)"
            )
            self.count = count
            self.endianness = endianness
        }
    }
}

extension Binary.Parse.Variable: Parsing {
    public var body: Never {
        borrowing get {
            return fatalError("\(Self.self) is a leaf: implement its conformance requirements directly")
        }
    }

    public typealias Input = ArraySlice<Byte>

    public typealias Output = T

    public typealias Failure = Parser::EndOfInput.Error

    @inlinable
    public func parse(_ input: inout Input) throws(Failure) -> T {
        guard input.count >= count else {
            throw .unexpected(expected: "\(count) bytes for variable-width integer")
        }

        let base = input.startIndex
        var result: T = 0

        switch endianness {
        case .little:

            (0..<count).forEach { i in
                let term = T(truncatingIfNeeded: input[base + i].bitPattern) << (i * 8)
                result |= term
            }

            if T.isSigned {

                let signBit = (input[base + count - 1].bitPattern & 0x80) != 0
                if signBit {

                    let shift = count * 8
                    if shift < T.bitWidth {
                        result |= ~T(0) << shift
                    }
                }
            }

        case .big:

            (0..<count).forEach { i in

                let term = T(truncatingIfNeeded: input[base + i].bitPattern) << ((count - 1 - i) * 8)
                result |= term
            }

            if T.isSigned {
                let signBit = (input[base].bitPattern & 0x80) != 0
                if signBit {

                    let shift = count * 8
                    if shift < T.bitWidth {
                        result |= ~T(0) << shift
                    }
                }
            }
        }

        input.removeFirst(count)
        return result
    }
}
