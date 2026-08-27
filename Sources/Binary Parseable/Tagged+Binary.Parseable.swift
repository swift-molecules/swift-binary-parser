@_spi(Internal) import Tagged

extension Tagged: Binary.Parseable where Underlying: Binary.Parseable {

    public static func parse<Source: RangeReplaceableCollection>(
        from source: inout Source
    ) throws(Binary.Parse.Failure) -> Tagged<Tag, Underlying>
    where Source.Element == Byte {
        let underlying = try Underlying.parse(from: &source)
        return Tagged(underlying)
    }
}
