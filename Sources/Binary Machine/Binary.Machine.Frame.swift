public import Checkpoint
public import Byte
import Index
public import Machine

extension Binary.Machine {

    public typealias Checkpoint = ArraySlice<Byte>.Checkpoint

    public typealias Frame<Position> = Machine.Machine.Frame<
        Node.ID, Position, Mode, Fault, Never
    >
}
