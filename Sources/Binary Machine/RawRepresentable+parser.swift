public import Byte
public import Byte
public import Cursor
public import Cursor
public import Cardinal
public import Ordinal

extension RawRepresentable where RawValue: FixedWidthInteger {

    public static var parser: Binary.Parser<Self> {
        Binary.Parser { input throws(Binary.Machine.Fault) in
            let size = MemoryLayout<RawValue>.size
            var bytes: [Byte] = []
            bytes.reserveCapacity(size)
            let needCount = Index<Byte>.Count(Cardinal(UInt(size)))
            for _ in 0..<size {
                guard !input.isEmpty else {
                    let have = Index<Byte>.Count(Cardinal(UInt(bytes.count)))
                    throw .insufficientBytes(need: needCount, have: have)
                }
                bytes.append(input.removeFirst())
            }
            guard let raw = RawValue(bytes: bytes, endianness: .little) else {
                throw .malformed
            }
            guard let value = Self(rawValue: raw) else {
                throw .outOfRange
            }
            return value
        }
    }
}
