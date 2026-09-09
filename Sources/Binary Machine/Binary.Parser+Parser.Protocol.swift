public import Byte
public import Byte
public import Cursor
public import Cursor

extension Binary.Parser: Parsing {

    public typealias Input = ArraySlice<Byte>

    public typealias Output = Value

    public typealias Failure = Binary.Machine.Fault

    public typealias Body = Never

    @inlinable
    public borrowing func parse(_ input: inout ArraySlice<Byte>) throws(Binary.Machine.Fault) -> Value {
        try _parse(&input)
    }
}
