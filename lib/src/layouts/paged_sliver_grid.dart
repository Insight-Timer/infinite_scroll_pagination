import 'package:flutter/widgets.dart';
import 'package:infinite_scroll_pagination/src/base/paged_child_builder_delegate.dart';
import 'package:infinite_scroll_pagination/src/core/paging_state.dart';
import 'package:infinite_scroll_pagination/src/helpers/appended_sliver_child_builder_delegate.dart';
import 'package:infinite_scroll_pagination/src/helpers/appended_sliver_grid.dart';
import 'package:infinite_scroll_pagination/src/helpers/banner_slivers.dart';
import 'package:infinite_scroll_pagination/src/base/paged_layout_builder.dart';
import 'package:infinite_scroll_pagination/src/layouts/paged_grid_view.dart';

/// Paged [SliverGrid] with progress and error indicators displayed as the last
/// item.
///
/// Similar to [PagedGridView] but needs to be wrapped by a
/// [CustomScrollView] when added to the screen.
/// Useful for combining multiple scrollable pieces in your UI or if you need
/// to add some widgets preceding or following your paged grid.
class PagedSliverGrid<PageKeyType, ItemType> extends StatelessWidget {
  const PagedSliverGrid({
    required this.state,
    required this.fetchNextPage,
    required this.builderDelegate,
    required this.gridDelegate,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.showNewPageProgressIndicatorAsGridChild = true,
    this.showNewPageErrorIndicatorAsGridChild = true,
    this.showNoMoreItemsIndicatorAsGridChild = true,
    this.shrinkWrapFirstPageIndicators = false,
    this.showBannersBetweenGridRows = false,
    this.bannerFrequency = 0,
    this.bannerWidgets,
    this.initialBannerIndex,
    super.key,
  });

  /// Matches [PagedLayoutBuilder.state].
  final PagingState<PageKeyType, ItemType> state;

  /// Matches [PagedLayoutBuilder.fetchNextPage].
  final NextPageCallback fetchNextPage;

  /// Matches [PagedLayoutBuilder.builderDelegate].
  final PagedChildBuilderDelegate<ItemType> builderDelegate;

  /// Matches [GridView.gridDelegate].
  final SliverGridDelegate gridDelegate;

  /// Matches [SliverChildBuilderDelegate.addAutomaticKeepAlives].
  final bool addAutomaticKeepAlives;

  /// Matches [SliverChildBuilderDelegate.addRepaintBoundaries].
  final bool addRepaintBoundaries;

  /// Matches [SliverChildBuilderDelegate.addSemanticIndexes].
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

  /// Matches [PagedLayoutBuilder.shrinkWrapFirstPageIndicators].
  final bool shrinkWrapFirstPageIndicators;

  /// Whether to show a banner between grid rows.
  final bool showBannersBetweenGridRows;

  /// Show a banner between grid items.
  final List<Widget>? bannerWidgets;

  /// The frequency of the banner.
  final int bannerFrequency;

  /// The index of the first banner.
  final int? initialBannerIndex;

  @override
  Widget build(BuildContext context) =>
      PagedLayoutBuilder<PageKeyType, ItemType>(
        layoutProtocol: PagedLayoutProtocol.sliver,
        state: state,
        fetchNextPage: fetchNextPage,
        builderDelegate: builderDelegate,
        completedListingBuilder: (
          context,
          itemBuilder,
          itemCount,
          noMoreItemsIndicatorBuilder,
        ) =>
            _buildSliverGrid(
          itemBuilder,
          itemCount,
          noMoreItemsIndicatorBuilder,
          showNoMoreItemsIndicatorAsGridChild,
        ),
        loadingListingBuilder: (
          context,
          itemBuilder,
          itemCount,
          progressIndicatorBuilder,
        ) =>
            _buildSliverGrid(
          itemBuilder,
          itemCount,
          progressIndicatorBuilder,
          showNewPageProgressIndicatorAsGridChild,
        ),
        errorListingBuilder: (
          context,
          itemBuilder,
          itemCount,
          errorIndicatorBuilder,
        ) =>
            _buildSliverGrid(
          itemBuilder,
          itemCount,
          errorIndicatorBuilder,
          showNewPageErrorIndicatorAsGridChild,
        ),
        shrinkWrapFirstPageIndicators: shrinkWrapFirstPageIndicators,
      );

  Widget _buildSliverGrid(
    IndexedWidgetBuilder itemBuilder,
    int itemCount,
    WidgetBuilder? appendixBuilder,
    bool showAppendixAsGridChild,
  ) {
    if (showBannersBetweenGridRows) {
      return BannerSlivers(
        itemBuilder: itemBuilder,
        itemCount: itemCount,
        segmentBuilder: (itemBuilder, itemCount) => SliverGrid(
          gridDelegate: gridDelegate,
          delegate: AppendedSliverChildBuilderDelegate(
            builder: itemBuilder,
            childCount: itemCount,
            addAutomaticKeepAlives: addAutomaticKeepAlives,
            addRepaintBoundaries: addRepaintBoundaries,
            addSemanticIndexes: addSemanticIndexes,
          ),
        ),
        bannerWidgets: bannerWidgets,
        bannerFrequency: bannerFrequency,
        initialBannerIndex: initialBannerIndex,
        appendixBuilder: appendixBuilder,
      );
    }

    return AppendedSliverGrid(
      sliverGridBuilder: (_, delegate) => SliverGrid(
        delegate: delegate,
        gridDelegate: gridDelegate,
      ),
      itemBuilder: itemBuilder,
      itemCount: itemCount,
      appendixBuilder: appendixBuilder,
      showAppendixAsGridChild: showAppendixAsGridChild,
      addAutomaticKeepAlives: addAutomaticKeepAlives,
      addSemanticIndexes: addSemanticIndexes,
      addRepaintBoundaries: addRepaintBoundaries,
    );
  }
}
