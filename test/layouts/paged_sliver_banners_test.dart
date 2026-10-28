import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../utils/paging_controller_utils.dart';
import '../utils/screen_size_utils.dart';

const double _tileHeight = 20;

const _bannerWidgets = [
  SizedBox(height: _tileHeight, child: Text('Banner A')),
  SizedBox(height: _tileHeight, child: Text('Banner B')),
];

void main() {
  group('PagedSliverList banners', () {
    testWidgets('Inserts the initial banner, then one every bannerFrequency',
        (tester) async {
      tester.applyPreferredTestScreenSize();

      await _pumpList(
        tester,
        state: TestPagingState.completed(n: 7),
        initialBannerIndex: 1,
        bannerFrequency: 3,
      );

      expect(_textsInVisualOrder(tester), [
        'Item 1',
        'Banner A',
        'Item 2',
        'Item 3',
        'Item 4',
        'Banner B',
        'Item 5',
        'Item 6',
        'Item 7',
      ]);
    });

    testWidgets('Cycles through banners and skips the trailing one',
        (tester) async {
      tester.applyPreferredTestScreenSize();

      await _pumpList(
        tester,
        state: TestPagingState.completed(n: 7),
        bannerFrequency: 2,
      );

      expect(_textsInVisualOrder(tester), [
        'Item 1',
        'Item 2',
        'Banner A',
        'Item 3',
        'Item 4',
        'Banner B',
        'Item 5',
        'Item 6',
        'Banner A',
        'Item 7',
      ]);
    });

    testWidgets('Shows the new page progress indicator below everything',
        (tester) async {
      tester.applyPreferredTestScreenSize();

      await _pumpList(
        tester,
        state: TestPagingState.ongoing(n: 4),
        bannerFrequency: 2,
        progressText: 'Loading',
      );

      expect(_textsInVisualOrder(tester), [
        'Item 1',
        'Item 2',
        'Banner A',
        'Item 3',
        'Item 4',
        'Loading',
      ]);
    });

    testWidgets('Renders no banners when disabled', (tester) async {
      tester.applyPreferredTestScreenSize();

      await _pumpList(
        tester,
        state: TestPagingState.completed(n: 4),
        bannerFrequency: 2,
        showBanners: false,
      );

      expect(find.textContaining('Banner'), findsNothing);
      expect(_textsInVisualOrder(tester), [
        'Item 1',
        'Item 2',
        'Item 3',
        'Item 4',
      ]);
    });
  });

  group('PagedSliverGrid banners', () {
    testWidgets('Inserts the initial banner, then one every bannerFrequency',
        (tester) async {
      tester.applyPreferredTestScreenSize();

      await _pumpGrid(
        tester,
        state: TestPagingState.completed(n: 6),
        initialBannerIndex: 2,
        bannerFrequency: 2,
      );

      expect(_textsInVisualOrder(tester), [
        'Item 1',
        'Item 2',
        'Banner A',
        'Item 3',
        'Item 4',
        'Banner B',
        'Item 5',
        'Item 6',
      ]);
    });

    testWidgets('Shows the new page progress indicator below everything',
        (tester) async {
      tester.applyPreferredTestScreenSize();

      await _pumpGrid(
        tester,
        state: TestPagingState.ongoing(n: 4),
        bannerFrequency: 2,
        progressText: 'Loading',
      );

      expect(_textsInVisualOrder(tester), [
        'Item 1',
        'Item 2',
        'Banner A',
        'Item 3',
        'Item 4',
        'Loading',
      ]);
      expect(
        tester.getSize(find.text('Loading').hitTestable()).width,
        lessThanOrEqualTo(screenSize.width),
      );
    });
  });
}

/// Sorts the visible texts by vertical, then horizontal, position.
List<String> _textsInVisualOrder(WidgetTester tester) {
  final entries = find
      .byType(Text)
      .evaluate()
      .map(
        (element) => (
          text: (element.widget as Text).data!,
          position: tester.getTopLeft(find.byElementPredicate(
            (candidate) => candidate == element,
          )),
        ),
      )
      .toList()
    ..sort((a, b) {
      final dy = a.position.dy.compareTo(b.position.dy);
      return dy != 0 ? dy : a.position.dx.compareTo(b.position.dx);
    });
  return entries.map((entry) => entry.text).toList();
}

PagedChildBuilderDelegate<String> _builderDelegate(String? progressText) =>
    PagedChildBuilderDelegate<String>(
      itemBuilder: buildTestTile(_tileHeight),
      newPageProgressIndicatorBuilder: progressText == null
          ? null
          : (_) => SizedBox(height: _tileHeight, child: Text(progressText)),
    );

Future<void> _pumpList(
  WidgetTester tester, {
  required PagingState<int, String> state,
  int bannerFrequency = 0,
  int? initialBannerIndex,
  bool showBanners = true,
  String? progressText,
}) =>
    tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomScrollView(
            slivers: [
              PagedSliverList<int, String>(
                state: state,
                fetchNextPage: () {},
                builderDelegate: _builderDelegate(progressText),
                showBannerBetweenListItems: showBanners,
                bannerFrequency: bannerFrequency,
                initialBannerIndex: initialBannerIndex,
                bannerWidgets: _bannerWidgets,
              ),
            ],
          ),
        ),
      ),
    );

Future<void> _pumpGrid(
  WidgetTester tester, {
  required PagingState<int, String> state,
  int bannerFrequency = 0,
  int? initialBannerIndex,
  String? progressText,
}) =>
    tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomScrollView(
            slivers: [
              PagedSliverGrid<int, String>(
                state: state,
                fetchNextPage: () {},
                builderDelegate: _builderDelegate(progressText),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisExtent: _tileHeight,
                ),
                showBannersBetweenGridRows: true,
                bannerFrequency: bannerFrequency,
                initialBannerIndex: initialBannerIndex,
                bannerWidgets: _bannerWidgets,
              ),
            ],
          ),
        ),
      ),
    );
