public import Binary
public import Parser

extension Parsing where Input == ArraySlice<Byte> {

    @inlinable
    public var parse: Binary.Parse.Access<Self> {
        .init(self)
    }
}
