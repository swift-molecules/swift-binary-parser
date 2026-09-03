public import Cardinal
public import Index
public import Ordinal_Protocol
public import Parser

extension Binary.Parse.Access {

    @inlinable
    public func prefix<Bytes: Swift.Collection>(
        _ bytes: Bytes
    ) throws(P.Failure) -> (value: P.Output, count: Index<Byte>.Count)
    where Bytes.Element == Byte {
        var input = Swift.Array(bytes)[...]
        let value = try parser.parse(&input)
        let consumed = Index<Byte>.Count(Cardinal(UInt(input.startIndex)))
        return (value: value, count: consumed)
    }
}
