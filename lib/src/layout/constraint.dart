import 'package:dt/foundation.dart';
import 'package:meta/meta.dart';

import 'axis.dart';
import 'layout.dart';

/// A constraint that can be applied to a layout.
@immutable
sealed class Constraint {
  /// Creates a constraint that specifies a fixed size.
  const factory Constraint.fixed(int size) = Fixed;

  /// Creates a constraint that specifies a flexible size based on a [weight].
  const factory Constraint.flex(int weight) = Flexible;

  const Constraint();
}

/// A constraint that specifies a fixed size.
///
/// Whether the size is a width or a height is determined by the context in
/// which the constraint is used.
final class Fixed extends Constraint {
  /// Creates a fixed constraint.
  const Fixed(
    this.size,
  ) : assert(size >= 0, 'Size must be non-negative');

  /// The fixed size.
  final int size;

  @override
  bool operator ==(Object other) {
    return other is Fixed && other.size == size;
  }

  @override
  int get hashCode => Object.hash(Fixed, size);

  @override
  String toString() => 'Fixed($size)';
}

/// A constraint that specifies a flexible size based on a [weight].
///
/// The ratio of the available space is determined by the weight of the
/// constraint.
final class Flexible extends Constraint {
  /// Creates a flexible constraint.
  const Flexible(
    this.weight,
  ) : assert(weight >= 0, 'Weight must be non-negative');

  /// The weight of the constraint.
  final int weight;

  @override
  bool operator ==(Object other) {
    return other is Flexible && other.weight == weight;
  }

  @override
  int get hashCode => Object.hash(Flexible, weight);

  @override
  String toString() => 'Flexible($weight)';
}

/// A layout that splits an area based on the provided [constraints].
///
/// The area is split into rows or columns based on the provided [axis].
final class Constrained implements LayoutSpec {
  /// Creates a layout that splits an area based on the provided constraints.
  const Constrained(this.constraints, {required this.axis});

  /// Creates a layout that splits an area horizontally.
  factory Constrained.horizontal(List<Constraint> constraints) {
    return Constrained(
      constraints,
      axis: Axis.horizontal,
    );
  }

  /// Creates a layout that splits an area vertically.
  factory Constrained.vertical(List<Constraint> constraints) {
    return Constrained(
      constraints,
      axis: Axis.vertical,
    );
  }

  /// The axis along which the area is split.
  final Axis axis;

  /// The constraints that determine the size of each split.
  final List<Constraint> constraints;

  @override
  List<Rect> split(Rect area) {
    var availableSpace = axis == Axis.horizontal ? area.height : area.width;
    var totalWeight = 0;

    final computedSize = List.filled(constraints.length, 0);
    for (final constraint in constraints) {
      switch (constraint) {
        case Fixed(:final size):
          availableSpace -= size;
        case Flexible(:final weight):
          totalWeight += weight;
      }
    }

    final perRatioSize = availableSpace / totalWeight;
    for (var i = 0; i < constraints.length; i++) {
      final constraint = constraints[i];
      switch (constraint) {
        case Fixed(:final size):
          computedSize[i] = size;
        case Flexible(:final weight):
          computedSize[i] = (perRatioSize * weight).floor();
      }
    }

    final splits = List.filled(constraints.length, Rect.zero);
    var offset = 0;
    for (var i = 0; i < computedSize.length; i++) {
      final size = computedSize[i];
      final Rect rect;
      if (axis == Axis.horizontal) {
        rect = Rect.fromLTWH(area.left, area.top + offset, area.width, size);
      } else {
        rect = Rect.fromLTWH(area.left + offset, area.top, size, area.height);
      }
      splits[i] = rect;
      offset += size;
    }

    return splits;
  }

  @override
  bool operator ==(Object other) {
    if (other is! Constrained ||
        other.axis != axis ||
        other.constraints.length != constraints.length) {
      return false;
    }
    for (var i = 0; i < constraints.length; i++) {
      if (constraints[i] != other.constraints[i]) {
        return false;
      }
    }
    return true;
  }

  @override
  int get hashCode {
    return Object.hash(Constrained, axis, Object.hashAll(constraints));
  }

  @override
  String toString() => 'Constrained.${axis.name}($constraints)';
}
