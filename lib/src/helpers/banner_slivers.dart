import 'package:flutter/widgets.dart';
import 'package:sliver_tools/sliver_tools.dart';

/// Builds a sliver that lays out [itemCount] items using [itemBuilder].
typedef BannerSegmentBuilder = Widget Function(
  IndexedWidgetBuilder itemBuilder,
  int itemCount,
);

/// Splits a paged layout into several slivers and inserts banners between
/// them.
///
/// The first banner goes after [initialBannerIndex] items, if set. After that,
/// a banner goes after every [bannerFrequency] items, cycling through
/// [bannerWidgets]. No banner is added after the last segment.
///
/// The [appendixBuilder] (status indicator) is always placed below all the
/// items.
class BannerSlivers extends StatelessWidget {
  const BannerSlivers({
    required this.itemBuilder,
    required this.itemCount,
    required this.segmentBuilder,
    this.bannerWidgets,
    this.bannerFrequency = 0,
    this.initialBannerIndex,
    this.appendixBuilder,
    super.key,
  });

  final IndexedWidgetBuilder itemBuilder;
  final int itemCount;
  final BannerSegmentBuilder segmentBuilder;
  final List<Widget>? bannerWidgets;
  final int bannerFrequency;
  final int? initialBannerIndex;
  final WidgetBuilder? appendixBuilder;

  @override
  Widget build(BuildContext context) {
    final slivers = <Widget>[];
    final banners = bannerWidgets ?? [];
    final initialBannerIndex = this.initialBannerIndex;
    final appendixBuilder = this.appendixBuilder;
    var bannerIndex = 0;
    var offset = 0;
    var remaining = itemCount;

    // Add initial banner if needed.
    if (initialBannerIndex != null && initialBannerIndex < itemCount) {
      slivers.add(segmentBuilder(itemBuilder, initialBannerIndex));

      if (banners.isNotEmpty) {
        slivers.add(SliverToBoxAdapter(child: banners[bannerIndex]));
        bannerIndex++;
      }

      offset = initialBannerIndex;
      remaining -= initialBannerIndex;
    }

    // Add the banners based on the frequency.
    if (bannerFrequency > 0 && bannerFrequency < remaining) {
      for (var start = 0; start < remaining; start += bannerFrequency) {
        final end = start + bannerFrequency < remaining
            ? start + bannerFrequency
            : remaining;
        final segmentOffset = offset + start;

        slivers.add(
          segmentBuilder(
            (context, index) => itemBuilder(context, segmentOffset + index),
            end - start,
          ),
        );

        if (banners.isNotEmpty && start + bannerFrequency < remaining) {
          if (bannerIndex >= banners.length) bannerIndex = 0;
          slivers.add(SliverToBoxAdapter(child: banners[bannerIndex]));
          bannerIndex++;
        }
      }
    } else {
      slivers.add(
        segmentBuilder(
          (context, index) => itemBuilder(context, offset + index),
          remaining,
        ),
      );
    }

    if (appendixBuilder != null) {
      slivers.add(SliverToBoxAdapter(child: appendixBuilder(context)));
    }

    return MultiSliver(children: slivers);
  }
}
