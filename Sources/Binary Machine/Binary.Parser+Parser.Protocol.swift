public import Binary
public import Byte
public import Cursor

extension Binary.Parser: Parsing {
    public var body: Never {
        borrowing get {
            return fatalError("\(Self.self) is a leaf: implement its conformance requirements directly")
        }
    }

    public typealias Input = ArraySlice<Byte>

    public typealias Output = Value

    public typealias Failure = Binary.Machine.Fault

    public typealias Body = Never

    @inlinable
    public borrowing func parse(_ input: inout ArraySlice<Byte>) throws(Binary.Machine.Fault) -> Value {
        try _parse(&input)
    }
}
