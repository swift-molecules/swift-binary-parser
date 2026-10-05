public import Binary

extension Binary.Parse {

    public struct Inline<let Count: Int, Element: FixedWidthInteger> {

        public let endianness: Binary.Endianness

        @inlinable
        public init(endianness: Binary.Endianness) {
            self.endianness = endianness
        }
    }
}

extension Binary.Parse.Inline: Parsing {
    public var body: Never {
        borrowing get {
            return fatalError("\(Self.self) is a leaf: implement its conformance requirements directly")
        }
    }

    public typealias Input = ArraySlice<Byte>

    public typealias Output = InlineArray<Count, Element>

    public typealias Failure = Parser::EndOfInput.Error

    @inlinable
    public func parse(_ input: inout Input) throws(Failure) -> Output {
        try Output(parsing: &input, endianness: endianness)
    }
}
