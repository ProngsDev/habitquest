import 'package:flutter/cupertino.dart';

import '../../../core/utils/responsive_utils.dart';

/// Responsive grid widget that adapts to screen size
class ResponsiveGrid extends StatelessWidget {

  const ResponsiveGrid({
    required this.children, super.key,
    this.spacing = 16,
    this.runSpacing = 16,
    this.forceColumns,
    this.padding,
  });
  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  final int? forceColumns;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final columns = forceColumns ?? ResponsiveUtils.getGridColumns(context);
    final responsivePadding = padding ?? ResponsiveUtils.getResponsivePadding(context);
    
    return Padding(
      padding: responsivePadding,
      child: _buildGrid(columns),
    );
  }

  Widget _buildGrid(int columns) {
    if (columns == 1) {
      return Column(
        children: children
            .map((child) => Padding(
                  padding: EdgeInsets.only(bottom: runSpacing),
                  child: child,
                ))
            .toList(),
      );
    }

    final rows = <Widget>[];
    for (var i = 0; i < children.length; i += columns) {
      final rowChildren = <Widget>[];
      
      for (var j = 0; j < columns; j++) {
        if (i + j < children.length) {
          rowChildren.add(
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: j < columns - 1 ? spacing : 0,
                ),
                child: children[i + j],
              ),
            ),
          );
        } else {
          rowChildren.add(const Expanded(child: SizedBox.shrink()));
        }
      }
      
      rows.add(
        Padding(
          padding: EdgeInsets.only(
            bottom: i + columns < children.length ? runSpacing : 0,
          ),
          child: Row(children: rowChildren),
        ),
      );
    }
    
    return Column(children: rows);
  }
}

/// Responsive staggered grid for cards of different heights
class ResponsiveStaggeredGrid extends StatelessWidget {

  const ResponsiveStaggeredGrid({
    required this.children, super.key,
    this.spacing = 16,
    this.forceColumns,
    this.padding,
  });
  final List<Widget> children;
  final double spacing;
  final int? forceColumns;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final columns = forceColumns ?? ResponsiveUtils.getGridColumns(context);
    final responsivePadding = padding ?? ResponsiveUtils.getResponsivePadding(context);
    
    if (columns == 1) {
      return Padding(
        padding: responsivePadding,
        child: Column(
          children: children
              .map((child) => Padding(
                    padding: EdgeInsets.only(bottom: spacing),
                    child: child,
                  ))
              .toList(),
        ),
      );
    }

    return Padding(
      padding: responsivePadding,
      child: _buildStaggeredGrid(columns),
    );
  }

  Widget _buildStaggeredGrid(int columns) {
    final columnChildren = List.generate(columns, (index) => <Widget>[]);
    
    // Distribute children across columns
    for (var i = 0; i < children.length; i++) {
      final columnIndex = i % columns;
      columnChildren[columnIndex].add(
        Padding(
          padding: EdgeInsets.only(bottom: spacing),
          child: children[i],
        ),
      );
    }
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: columnChildren
          .asMap()
          .entries
          .map((entry) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: entry.key < columns - 1 ? spacing : 0,
                  ),
                  child: Column(children: entry.value),
                ),
              ))
          .toList(),
    );
  }
}

/// Responsive wrap widget that adapts spacing to screen size
class ResponsiveWrap extends StatelessWidget {

  const ResponsiveWrap({
    required this.children, super.key,
    this.direction = Axis.horizontal,
    this.alignment = WrapAlignment.start,
    this.crossAxisAlignment = WrapCrossAlignment.start,
    this.padding,
  });
  final List<Widget> children;
  final Axis direction;
  final WrapAlignment alignment;
  final WrapCrossAlignment crossAxisAlignment;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final spacing = ResponsiveUtils.getResponsiveSpacing(context);
    final responsivePadding = padding ?? ResponsiveUtils.getResponsivePadding(context);
    
    return Padding(
      padding: responsivePadding,
      child: Wrap(
        direction: direction,
        alignment: alignment,
        crossAxisAlignment: crossAxisAlignment,
        spacing: spacing,
        runSpacing: spacing,
        children: children,
      ),
    );
  }
}

/// Responsive list view with adaptive spacing
class ResponsiveListView extends StatelessWidget {

  const ResponsiveListView({
    required this.children, super.key,
    this.physics,
    this.shrinkWrap = false,
    this.padding,
  });
  final List<Widget> children;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final responsivePadding = padding ?? ResponsiveUtils.getResponsivePadding(context);
    final spacing = ResponsiveUtils.getResponsiveSpacing(context);
    
    return ListView.separated(
      physics: physics,
      shrinkWrap: shrinkWrap,
      padding: responsivePadding,
      itemCount: children.length,
      separatorBuilder: (context, index) => SizedBox(height: spacing),
      itemBuilder: (context, index) => children[index],
    );
  }
}

/// Responsive card that adapts its width to screen size
class ResponsiveCard extends StatelessWidget {

  const ResponsiveCard({
    required this.child, super.key,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.onTap,
  });
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cardWidth = ResponsiveUtils.getCardWidth(context);
    final responsivePadding = padding ?? ResponsiveUtils.getResponsivePadding(context);
    final responsiveMargin = margin ?? ResponsiveUtils.getResponsiveMargin(context);
    
    Widget cardContent = Container(
      width: cardWidth,
      padding: responsivePadding,
      margin: responsiveMargin,
      decoration: BoxDecoration(
        color: backgroundColor ?? CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );

    if (onTap != null) {
      cardContent = GestureDetector(
        onTap: onTap,
        child: cardContent,
      );
    }

    return cardContent;
  }
}
