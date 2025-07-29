pub type NodeIndex = u16;
pub const NIL: NodeIndex = u16::MAX;

#[repr(C)]
/// A node in the stack of unallocated sectors.
struct StackNode {
    /// Sector index of the next node in the stack, `NIL` if no next node.
    next: NodeIndex,
}
