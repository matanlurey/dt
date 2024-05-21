/// Represents a terminal _buffer_, an append-only sequence of lines.
library;

abstract mixin class BufferSink<T> {}

abstract mixin class BufferView<T> {}

abstract class Buffer<T> with BufferView<T>, BufferSink<T> {}

base class _StringBuffer extends Buffer<String> {}
