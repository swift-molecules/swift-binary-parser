public import Binary
import Graph
public import Machine
import Vector

public import Binary
import Graph
public import Machine
import Vector

extension Binary.Machine {
    public struct Expression<Output> {
        @usableFromInline
        let node: Node.ID

        @usableFromInline
        init(node: Node.ID) {
            self.node = node
        }
    }
}
