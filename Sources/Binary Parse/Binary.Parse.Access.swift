public import Parser

extension Binary.Parse {

    public struct Access<P: Parser.`Protocol`>
    where P.Input == Byte.Input, P.Output: Copyable & Escapable {
        @usableFromInline
        internal let parser: P

        @inlinable
        public init(_ parser: P) {
            self.parser = parser
        }
    }
}
