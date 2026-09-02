public import Byte
public import Index
public import Ordinal_Protocol

extension Binary.Parse {

    public enum Error: Swift.Error, Sendable, Equatable {

        case end(remaining: Index<Byte>.Count)
    }
}
