import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:infinite_scroll_pagination/src/core/paged_child_builder_delegate.dart';
import 'package:infinite_scroll_pagination/src/core/paging_controller.dart';
import 'package:infinite_scroll_pagination/src/ui/paged_grid_view.dart';
import 'package:infinite_scroll_pagination/src/ui/paged_sliver_builder.dart';
import 'package:infinite_scroll_pagination/src/utils/appended_sliver_child_builder_delegate.dart';
import 'package:sliver_tools/sliver_tools.dart';

/// Paged [SliverGrid] with progress and error indicators displayed as the last
/// item.
///
/// Similar to [PagedGridView] but needs to be wrapped by a
/// [CustomScrollView] when added to the screen.
/// Useful for combining multiple scrollable pieces in your UI or if you need
/// to add some widgets preceding or following your paged grid.
class PagedSliverGrid<PageKeyType, ItemType> extends StatelessWidget {
  const PagedSliverGrid({
    required this.pagingController,
    required this.builderDelegate,
    required this.gridDelegate,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.showNewPageProgressIndicatorAsGridChild = true,
    this.showNewPageErrorIndicatorAsGridChild = true,
    this.showNoMoreItemsIndicatorAsGridChild = true,
    this.shrinkWrapFirstPageIndicators = false,
    this.showBannerBetweenGridItems = false,
    this.bannerFrequency = 0,
    this.bannerWidgets,
    this.initialBannerIndex,
    Key? key,
  }) : super(key: key);

  /// Corresponds to [PagedSliverBuilder.pagingController].
  final PagingController<PageKeyType, ItemType> pagingController;

  /// Corresponds to [PagedSliverBuilder.builderDelegate].
  final PagedChildBuilderDelegate<ItemType> builderDelegate;

  /// Corresponds to [GridView.gridDelegate].
  final SliverGridDelegate gridDelegate;

  /// Corresponds to [SliverChildBuilderDelegate.addAutomaticKeepAlives].
  final bool addAutomaticKeepAlives;

  /// Corresponds to [SliverChildBuilderDelegate.addRepaintBoundaries].
  final bool addRepaintBoundaries;

  /// Corresponds to [SliverChildBuilderDelegate.addSemanticIndexes].
  final bool addSemanticIndexes;

  /// Whether the new page progress indicator should display as a grid child
  /// or put below the grid.
  ///
  /// Defaults to true.
  final bool showNewPageProgressIndicatorAsGridChild;

  /// Whether the new page error indicator should display as a grid child
  /// or put below the grid.
  ///
  /// Defaults to true.
  final bool showNewPageErrorIndicatorAsGridChild;

  /// Whether the no more items indicator should display as a grid child
  /// or put below the grid.
  ///
  /// Defaults to true.
  final bool showNoMoreItemsIndicatorAsGridChild;

  /// Corresponds to [PagedSliverBuilder.shrinkWrapFirstPageIndicators].
  final bool shrinkWrapFirstPageIndicators;

  /// Whether to show a banner between grid items.
  final bool showBannerBetweenGridItems;

  /// Show a banner between grid items.
  final List<Widget>? bannerWidgets;

  /// The frequency of the banner.
  final int bannerFrequency;

  /// The index of the first banner.
  final int? initialBannerIndex;

  @override
  Widget build(BuildContext context) => PagedSliverBuilder<PageKeyType, ItemType>(
        pagingController: pagingController,
        builderDelegate: builderDelegate,
        completedListingBuilder: (
          context,
          itemBuilder,
          itemCount,
          noMoreItemsIndicatorBuilder,
        ) =>
            _AppendedSliverGrid(
          gridDelegate: gridDelegate,
          itemBuilder: itemBuilder,
          itemCount: itemCount,
          appendixBuilder: noMoreItemsIndicatorBuilder,
          showAppendixAsGridChild: showNoMoreItemsIndicatorAsGridChild,
          addAutomaticKeepAlives: addAutomaticKeepAlives,
          addSemanticIndexes: addSemanticIndexes,
          addRepaintBoundaries: addRepaintBoundaries,
          showBannerBetweenGridItems: showBannerBetweenGridItems,
          bannerFrequency: bannerFrequency,
          bannerWidgets: bannerWidgets,
          initialBannerIndex: initialBannerIndex,
        ),
        loadingListingBuilder: (
          context,
          itemBuilder,
          itemCount,
          progressIndicatorBuilder,
        ) =>
            _AppendedSliverGrid(
          gridDelegate: gridDelegate,
          itemBuilder: itemBuilder,
          itemCount: itemCount,
          appendixBuilder: progressIndicatorBuilder,
          showAppendixAsGridChild: showNewPageProgressIndicatorAsGridChild,
          addAutomaticKeepAlives: addAutomaticKeepAlives,
          addSemanticIndexes: addSemanticIndexes,
          addRepaintBoundaries: addRepaintBoundaries,
          showBannerBetweenGridItems: showBannerBetweenGridItems,
          bannerFrequency: bannerFrequency,
          bannerWidgets: bannerWidgets,
          initialBannerIndex: initialBannerIndex,
        ),
        errorListingBuilder: (
          context,
          itemBuilder,
          itemCount,
          errorIndicatorBuilder,
        ) =>
            _AppendedSliverGrid(
          gridDelegate: gridDelegate,
          itemBuilder: itemBuilder,
          itemCount: itemCount,
          appendixBuilder: errorIndicatorBuilder,
          showAppendixAsGridChild: showNewPageErrorIndicatorAsGridChild,
          addAutomaticKeepAlives: addAutomaticKeepAlives,
          addSemanticIndexes: addSemanticIndexes,
          addRepaintBoundaries: addRepaintBoundaries,
          showBannerBetweenGridItems: showBannerBetweenGridItems,
          bannerFrequency: bannerFrequency,
          bannerWidgets: bannerWidgets,
          initialBannerIndex: initialBannerIndex,
        ),
        shrinkWrapFirstPageIndicators: shrinkWrapFirstPageIndicators,
      );
}

class _AppendedSliverGrid extends StatelessWidget {
  const _AppendedSliverGrid({
    required this.gridDelegate,
    required this.itemBuilder,
    required this.itemCount,
    this.showAppendixAsGridChild = true,
    this.appendixBuilder,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.showBannerBetweenGridItems = false,
    this.bannerFrequency = 0,
    this.bannerWidgets,
    this.initialBannerIndex,
    Key? key,
  }) : super(key: key);

  final SliverGridDelegate gridDelegate;
  final IndexedWidgetBuilder itemBuilder;
  final int itemCount;
  final bool showAppendixAsGridChild;
  final WidgetBuilder? appendixBuilder;
  final bool addAutomaticKeepAlives;
  final bool addRepaintBoundaries;
  final bool addSemanticIndexes;
  final bool showBannerBetweenGridItems;
  final List<Widget>? bannerWidgets;
  final int bannerFrequency;
  final int? initialBannerIndex;

  @override
  Widget build(BuildContext context) {
    if (showBannerBetweenGridItems) {
      return _buildMultipleGridViewWithBanner(context, itemCount);
    }

    if (showAppendixAsGridChild == true || appendixBuilder == null) {
      return SliverGrid(
        gridDelegate: gridDelegate,
        delegate: _buildSliverDelegate(
          appendixBuilder: appendixBuilder,
        ),
      );
    } else {
      return MultiSliver(children: [
        SliverGrid(
          gridDelegate: gridDelegate,
          delegate: _buildSliverDelegate(),
        ),
        SliverToBoxAdapter(
          child: appendixBuilder!(context),
        ),
      ]);
    }
  }

  Widget _buildMultipleGridViewWithBanner(BuildContext context, int itemCount) {
    final items = List<int>.generate(itemCount, (i) => i + 1);
    final slivers = <Widget>[];
    final banners = bannerWidgets ?? [];
    var bannerIndex = 0;
    final initialBannerIndex = this.initialBannerIndex;

    // Add initial banner if needed.
    if (initialBannerIndex != null && initialBannerIndex < itemCount) {
      final endIndex = initialBannerIndex;
      final subList = items.sublist(0, endIndex);

      slivers.add(
        SliverGrid(
          gridDelegate: gridDelegate,
          delegate: _buildSliverDelegate(count: subList.length, builder: itemBuilder),
        ),
      );

      if (banners.isNotEmpty) {
        slivers.add(SliverToBoxAdapter(child: banners[bannerIndex]));
        bannerIndex++;
      }

      itemCount -= endIndex;
      items.removeRange(0, endIndex);
    }

    // Add the banners based on the frequency.
    if (bannerFrequency > 0 && bannerFrequency < itemCount) {
      for (var bannerFrequencyIndex = 0; bannerFrequencyIndex < itemCount; bannerFrequencyIndex += bannerFrequency) {
        final endIndex =
            (bannerFrequencyIndex + bannerFrequency < itemCount) ? bannerFrequencyIndex + bannerFrequency : itemCount;
        final subList = items.sublist(bannerFrequencyIndex, endIndex);
        slivers.add(
          SliverGrid(
            gridDelegate: gridDelegate,
            delegate: _buildSliverDelegate(
              count: subList.length,
              builder: (context, index) => itemBuilder(context, subList[index] - 1),
            ),
          ),
        );
        if (banners.isNotEmpty && bannerFrequencyIndex + bannerFrequency < itemCount) {
          if (bannerIndex >= banners.length) bannerIndex = 0;
          slivers.add(SliverToBoxAdapter(child: banners[bannerIndex]));
          bannerIndex++;
        }
      }
    } else {
      slivers.add(
        SliverGrid(
          gridDelegate: gridDelegate,
          delegate: _buildSliverDelegate(
            count: itemCount,
            builder: (context, index) => itemBuilder(context, items[index] - 1),
          ),
        ),
      );
    }

    if (appendixBuilder != null) {
      slivers.add(SliverToBoxAdapter(child: appendixBuilder!(context)));
    }

    return MultiSliver(children: slivers);
  }

  SliverChildBuilderDelegate _buildSliverDelegate({
    IndexedWidgetBuilder? builder,
    WidgetBuilder? appendixBuilder,
    int? count,
  }) =>
      AppendedSliverChildBuilderDelegate(
        builder: builder ?? itemBuilder,
        childCount: count ?? itemCount,
        appendixBuilder: appendixBuilder,
        addAutomaticKeepAlives: addAutomaticKeepAlives,
        addRepaintBoundaries: addRepaintBoundaries,
        addSemanticIndexes: addSemanticIndexes,
      );
}
