public import Binary
import Parser
public import Cardinal
public import Index
public import Ordinal

extension Binary.Parse {

    public struct Access<P: Parsing>
    where P.Input == ArraySlice<Byte>, P.Output: Copyable & Escapable {
        @usableFromInline
        internal let parser: P

        @inlinable
        public init(_ parser: P) {
            self.parser = parser
        }
    }
}

extension Binary.Parse.Access {

    @inlinable
    public func prefix<Bytes: Swift::Collection>(
        _ bytes: Bytes
    ) throws(P.Failure) -> (value: P.Output, count: Index<Byte>.Count)
    where Bytes.Element == Byte {
        var input = Swift::Array(bytes)[...]
        let value = try parser.parse(&input)
        let consumed = Index<Byte>.Count(Cardinal(UInt(input.startIndex)))
        return (value: value, count: consumed)
    }
}

extension Binary.Parse.Access {

    @inlinable
    public func whole<Bytes: Swift::Collection>(
        _ bytes: Bytes
    ) throws(Either<P.Failure, Binary.Parse.Error>) -> P.Output
    where Bytes.Element == Byte {
        var input = Swift::Array(bytes)[...]
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
