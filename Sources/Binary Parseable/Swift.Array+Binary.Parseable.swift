public import Binary
public import Binary_Parse

extension Swift.Array: Binary.Parseable where Element == Byte {

    public static func parse<Source: RangeReplaceableCollection>(
        from source: inout Source
    ) throws(Binary.Parse.Failure) -> Self
    where Source.Element == Byte {
        var bytes = Self()

        bytes.reserveCapacity(source.count)
        for byte in source {
            bytes.append(byte)
        }
        source.removeAll(keepingCapacity: false)
        return bytes
    }
}
