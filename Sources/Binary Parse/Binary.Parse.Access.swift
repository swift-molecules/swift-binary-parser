public import Binary
public import Parser

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
