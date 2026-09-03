public import Byte
public import Byte_Standard_Library_Integration
public import Cursor
public import Cursor_Standard_Library_Integration

extension Binary.Parser: Parser.`Protocol` {

    public typealias Input = ArraySlice<Byte>

    public typealias Output = Value

    public typealias Failure = Binary.Machine.Fault

    public typealias Body = Never

    @inlinable
    public borrowing func parse(_ input: inout ArraySlice<Byte>) throws(Binary.Machine.Fault) -> Value {
        try _parse(&input)
    }
}
