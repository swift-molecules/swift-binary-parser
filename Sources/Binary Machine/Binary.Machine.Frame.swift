import Index
public import Machine

extension Binary.Machine {

    public typealias Checkpoint = Index<Byte>

    public typealias Frame = Machine.Machine.Frame<
        Node.ID, Checkpoint, Mode, Fault, Never
    >
}
