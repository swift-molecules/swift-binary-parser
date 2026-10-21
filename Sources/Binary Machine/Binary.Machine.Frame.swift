public import Binary
public import Byte
public import Checkpoint
import Index
public import Machine

extension Binary.Machine {

    public typealias Checkpoint = ArraySlice<Byte>.Checkpoint

    public typealias Frame<Position> = Machine::Machine.Frame<
        Node.ID, Position, Mode, Fault, Never
    >
}
