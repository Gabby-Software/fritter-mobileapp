import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fritter/client.dart';
import 'package:fritter/loading.dart';
import 'package:fritter/tweet.dart';
import 'package:intl/intl.dart';

import 'models.dart';

class ProfileScreen extends StatelessWidget {
  final String username;

  const ProfileScreen({Key key, this.username}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ProfileScreenBody(username: username),
    );
  }
}

class ProfileScreenBody extends StatefulWidget {
  final String username;

  const ProfileScreenBody({Key key, this.username}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ProfileScreenBodyState();
}

class _ProfileScreenBodyState extends State<ProfileScreenBody> {
  final double _appBarHeight = 256.0;

  bool _loading = true;
  Profile _profile = Profile(null, null, 'Loading...', 0, 0, 0, List(), '', false);
  Iterable<Tweet> _tweets = List();

  StreamSubscription _sub;

  @override
  void initState() {
    super.initState();
    fetchProfile(widget.username);
  }

  void fetchProfile(String username) {
    setState(() {
      _loading = true;
    });

    TwitterClient.getProfile(username)
        .then((profile) => setState(() {
              _profile = profile;
              _tweets = profile.tweets;
            }))
        .catchError((Exception e) => Scaffold.of(context).showSnackBar(SnackBar(
              content: Text('Something went wrong loading the profile! The error was: $e'),
              duration: Duration(days: 1),
              action: SnackBarAction(
                label: 'Retry',
                onPressed: () => fetchProfile(username),
              ),
            )))
        .whenComplete(() => setState(() {
              _loading = false;
            }));
  }

  @override
  void didUpdateWidget(ProfileScreenBody oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.username != widget.username) {
      fetchProfile(widget.username);
    }
  }

  @override
  Widget build(BuildContext context) {
    var numberFormat = NumberFormat.compact();

    var tweets = _tweets.map((tweet) {
      return TweetTile(currentUsername: widget.username, tweet: tweet);
    }).toList();

    var bannerImage = _profile.banner == null
        ? Container()
        : Image.network(_profile.banner, fit: BoxFit.cover, height: _appBarHeight);

    return Scaffold(
        body: DefaultTabController(
          length: 3,
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: _appBarHeight,
                pinned: true,
                bottom: TabBar(
                  tabs: [
                    Tab(child: Column(
                      children: [
                        Text('Tweets', style: Theme.of(context).primaryTextTheme.subtitle2),
                        Text('${numberFormat.format(_profile.numberOfTweets)}', style: Theme.of(context).primaryTextTheme.headline6),
                      ],
                    )),
                    Tab(child: Column(
                      children: [
                        Text('Following', style: Theme.of(context).primaryTextTheme.subtitle2),
                        Text('${numberFormat.format(_profile.numberOfFollowing)}', style: Theme.of(context).primaryTextTheme.headline6),
                      ],
                    )),
                    Tab(child: Column(
                      children: [
                        Text('Followers', style: Theme.of(context).primaryTextTheme.subtitle2),
                        Text('${numberFormat.format(_profile.numberOfFollowers)}', style: Theme.of(context).primaryTextTheme.headline6),
                      ],
                    )),
                  ],
                ),
                title: Text(_profile.fullName),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: <Widget>[
                      bannerImage,
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: <Color>[Color(0xBB000000), Color(0x50000000)],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                  child: LoadingStack(
                    loading: _loading,
                    child: Column(children: tweets),
                  )
              ),
            ],
          ),
        )
    );
  }

  @override
  void dispose() {
    super.dispose();
    if (_sub != null) {
      _sub.cancel();
    }
  }
}