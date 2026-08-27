public import Byte
public import Index

extension Binary.Parse {

    public enum Error: Swift.Error, Sendable, Equatable {

        case end(remaining: Index<Byte>.Count)
    }
}
