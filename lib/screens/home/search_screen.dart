import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key,}) : super(key: key);
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchQueryController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching ? _buildSearchField() : const Text('Search'),
        actions: _buildActions(),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchQueryController,
      autofocus: true,
      decoration: const InputDecoration(
        hintText: 'Search...',
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.white),
      ),
      style: const TextStyle(color: Colors.white, fontSize: 16.0),
      onChanged: (query) => setState(() => _searchQuery = query),
    );
  }

  List<Widget> _buildActions() {
    if (_isSearching) {
      return [
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            setState(() {
              _searchQueryController.clear();
              _searchQuery = '';
              _isSearching = false;
            });
          },
        ),
      ];
    } else {
      return [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () => setState(() => _isSearching = true),
        ),
      ];
    }
  }

  Widget _buildBody() {
    if (_searchQuery.isEmpty) {
      return const Center(
        child: Text(
          'Enter a search query to get started',
          style: TextStyle(fontSize: 16.0),
        ),
      );
    } else {
      return DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(text: 'Users'),
                Tab(text: 'Posts'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildUserResults(),
                  _buildPostResults(),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildUserResults() {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
          leading: const CircleAvatar(),
          title: Text('User $index'),
        );
      },
    );
  }

  Widget _buildPostResults() {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
          leading: const CircleAvatar(),
          title: Text('Post $index'),
        );
      },
    );
  }
}

