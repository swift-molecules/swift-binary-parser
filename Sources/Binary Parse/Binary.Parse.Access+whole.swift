public import Cardinal
public import Index
public import Ordinal_Protocol
public import Parser

extension Binary.Parse.Access {

    @inlinable
    public func whole<Bytes: Swift.Collection>(
        _ bytes: Bytes
    ) throws(Either<P.Failure, Binary.Parse.Error>) -> P.Output
    where Bytes.Element == Byte {
        var input = Swift.Array(bytes)[...]
        let value: P.Output
        do throws(P.Failure) {
            value = try parser.parse(&input)
        } catch {
            throw .left(error)
        }
        guard input.isEmpty else {
            throw .right(.end(remaining: Index<Byte>.Count(Cardinal(UInt(input.count)))))
        }
        return value
    }
}
