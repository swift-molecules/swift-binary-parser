public import Parser

extension Parser.`Protocol` where Input == ArraySlice<Byte> {

    @inlinable
    public var parse: Binary.Parse.Access<Self> {
        .init(self)
    }
}
