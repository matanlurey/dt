import 'package:meta/meta.dart';

import 'axis.dart';
import 'constraint.dart';
import 'flex.dart';
import 'margin.dart';

/// A set of constraints applied to a given area to split it into smaller ones.
///
/// A layout is composed of:
/// - [direction] the layout is split by;
/// - [constraints] that define how the area is divided;
/// - [margin] that defines the space around the layout;
/// - [distribution] for defining how the space is distributed;
/// - [spacing] between each layout element.
@immutable
final class Layout {
  /// Creates a new layout from the given [direction] and [constraints].
  ///
  /// Defaults to a layout with no margin, a start distribution, and no spacing.
  Layout(
    this.direction,
    Iterable<Constraint> constraints, {
    this.margin = Margin.zero,
    this.distribution = Flex.start,
    int spacing = 0,
  })  : constraints = List.unmodifiable([...constraints]..sort()),
        spacing = spacing < 0 ? 0 : spacing;

  /// Creates a new vertical layout from the given [constraints].
  ///
  /// Defaults to a layout with no margin, a start distribution, and no spacing.
  factory Layout.vertical(
    Iterable<Constraint> constraints, {
    Margin margin = Margin.zero,
    Flex distribution = Flex.start,
    int spacing = 0,
  }) {
    return Layout(
      Axis.vertical,
      constraints,
      margin: margin,
      distribution: distribution,
      spacing: spacing,
    );
  }

  /// Creates a new horizontal layout from the given [constraints].
  ///
  /// Defaults to a layout with no margin, a start distribution, and no spacing.
  factory Layout.horizontal(
    Iterable<Constraint> constraints, {
    Margin margin = Margin.zero,
    Flex distribution = Flex.start,
    int spacing = 0,
  }) {
    return Layout(
      Axis.horizontal,
      constraints,
      margin: margin,
      distribution: distribution,
      spacing: spacing,
    );
  }

  /// How the layout is split.
  final Axis direction;

  /// Constraints applied to the layout.
  ///
  /// The constraints are applied in the order they are listed and are always
  /// ordered by their precedence (see [Constraint] for more information).
  ///
  /// This list is unmodifiable.
  final List<Constraint> constraints;

  /// The space around the layout.
  final Margin margin;

  /// How the space is distributed.
  final Flex distribution;

  /// The spacing between each layout element.
  ///
  /// A negative value is clamped to zero.
  final int spacing;

  @override
  bool operator ==(Object other) {
    if (other is! Layout) {
      return false;
    }

    if (identical(this, other)) {
      return true;
    }

    // Check the cheap properties first.
    if (direction != other.direction ||
        margin != other.margin ||
        distribution != other.distribution ||
        spacing != other.spacing ||
        constraints.length != other.constraints.length) {
      return false;
    }

    // Check the constraints.
    for (var i = 0; i < constraints.length; i++) {
      if (constraints[i] != other.constraints[i]) {
        return false;
      }
    }

    return true;
  }

  @override
  int get hashCode {
    return Object.hash(
      direction,
      margin,
      distribution,
      spacing,
      Object.hashAll(constraints),
    );
  }

  /// Creates a copy of this layout with the given properties replaced.
  ///
  /// If no new values are provided, the original values are used.
  Layout copyWith({
    Axis? direction,
    List<Constraint>? constraints,
    Margin? margin,
    Flex? distribution,
    int? spacing,
  }) {
    return Layout(
      direction ?? this.direction,
      constraints ?? this.constraints,
      margin: margin ?? this.margin,
      distribution: distribution ?? this.distribution,
      spacing: spacing ?? this.spacing,
    );
  }

  @override
  String toString() {
    // ignore: noop_primitive_operations
    return ''
        'Layout'
        '('
        '$direction, '
        '$constraints, '
        'margin: $margin, '
        'distribution: $distribution, '
        'spacing: $spacing'
        ')';
  }
}
