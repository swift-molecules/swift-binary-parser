public import Buffer_Linear_Primitive
public import Buffer_Linear
internal import Index
public import Ownership_Shared_Primitive
public import Parser

extension Binary.Parse.Access {

    @inlinable
    public func prefix<Bytes: Swift.Collection>(
        _ bytes: Bytes
    ) throws(P.Failure) -> (value: P.Output, count: Index<Byte>.Count)
    where Bytes.Element == Byte {
        var input = Byte.Input(bytes)
        let value = try parser.parse(&input)
        return (value: value, count: input.consumed)
    }
}
