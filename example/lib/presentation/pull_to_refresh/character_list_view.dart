import 'package:breaking_bapp/character_summary.dart';
import 'package:breaking_bapp/presentation/common/character_list_item.dart';
import 'package:breaking_bapp/remote_api.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class CharacterListView extends StatefulWidget {
  @override
  _CharacterListViewState createState() => _CharacterListViewState();
}

class _CharacterListViewState extends State<CharacterListView> {
  static const _pageSize = 20;

  final PagingController<int, CharacterSummary> _pagingController = PagingController(firstPageKey: 0);

  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    super.initState();
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final newItems = await RemoteApi.getCharacterList(pageKey, _pageSize);

      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + newItems.length;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  Widget build(BuildContext context) => RefreshIndicator(
        onRefresh: () => Future.sync(
          () => _pagingController.refresh(),
        ),
        child: CustomScrollView(slivers: [
          PagedSliverList<int, CharacterSummary>.separated(
            pagingController: _pagingController,
            builderDelegate: PagedChildBuilderDelegate<CharacterSummary>(
              animateTransitions: true,
              itemBuilder: (context, item, index) => CharacterListItem(
                character: item,
                index: index,
              ),
            ),
            separatorBuilder: (context, index) => const Divider(),
            initialBannerIndex: 1,
            bannerFrequency: 3,
            bannerWidgets: [
              _buildBannerWidget(context, color: Colors.yellow),
              _buildBannerWidget(context, color: Colors.blue),
            ],
            showBannerBetweenListItems: true,
          ),
        ]),
      );

  Widget _buildBannerWidget(BuildContext context, {required Color color}) => Container(
        height: 50,
        color: color,
        alignment: Alignment.center,
        child: const Text(
          'Banner',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      );

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }
}
