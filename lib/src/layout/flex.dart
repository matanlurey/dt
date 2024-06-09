/// Defines the options for justifying the layout of a container.
///
/// When layout constraints are met, the container will be aligned accordingly.
enum Flex {
  /// Aligns items to the start of the container.
  start,

  /// Aligns items to the end of the container.
  end,

  /// Aligns items to the center of the container.
  center,

  /// Adds excess space between each element.
  spaceBetween,

  /// Adds excess space around each element.
  spaceAround;
}
