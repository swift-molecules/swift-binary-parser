public import Binary
public import Binary_Parse
import Byte

extension Binary {

    public protocol Parseable: Sendable {

        static func parse<Source: RangeReplaceableCollection>(
            from source: inout Source
        ) throws(Binary.Parse.Failure) -> Self
        where Source.Element == Byte
    }
}
