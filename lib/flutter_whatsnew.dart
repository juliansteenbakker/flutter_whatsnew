library flutter_whatsnew;

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class WhatsNewPage extends StatelessWidget {
  final Widget title;
  final Widget buttonText;
  final List<ListTile>? items;
  final VoidCallback? onButtonPressed;
  final bool changelog;
  final String? changes;
  final Color? backgroundColor;
  final Color? buttonColor;
  final String? path;
  final MarkdownTapLinkCallback? onTapLink;

  const WhatsNewPage({
    required this.items,
    required this.title,
    required this.buttonText,
    this.onButtonPressed,
    this.backgroundColor,
    this.buttonColor,
    this.onTapLink,
  })  : changelog = false,
        changes = null,
        path = null;

  const WhatsNewPage.changelog({
    required this.title,
    required this.buttonText,
    this.onButtonPressed,
    this.changes,
    this.backgroundColor,
    this.buttonColor,
    this.path,
    this.onTapLink,
  })  : changelog = true,
        items = null;

  static void showDetailPopUp(
      BuildContext context, String title, String detail) async {
    void showDemoDialog<T>({
      required BuildContext context,
      required Widget child,
    }) {
      showDialog<T>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => child,
      );
    }

    return showDemoDialog<Null>(
      context: context,
      child: AlertDialog(
        title: Text(title),
        content: Text(detail),
        actions: <Widget>[
          TextButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("Changelog: $changelog");
    assert(items != null || changelog);
    if (!kIsWeb && Platform.isIOS) {
      return _buildIOS(context);
    }

    return _buildAndroid(context);
  }

  Widget _buildAndroid(BuildContext context) {
    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: buttonColor ?? Theme.of(context).colorScheme.primary,
      foregroundColor: buttonColor != null
          ? (buttonColor!.computeLuminance() > 0.5
              ? Colors.black
              : Colors.white)
          : Theme.of(context).colorScheme.onPrimary,
    );
    if (changelog) {
      return Scaffold(
        backgroundColor:
            backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: Stack(
            fit: StackFit.loose,
            children: <Widget>[
              Positioned(
                top: 10.0,
                left: 0.0,
                right: 0.0,
                child: title,
              ),
              Positioned(
                left: 0.0,
                right: 0.0,
                top: 50.0,
                bottom: 80.0,
                child: ChangeLogView(
                  changes: changes,
                  path: path,
                  onTapLink: onTapLink,
                ),
              ),
              Positioned(
                bottom: 5.0,
                right: 10.0,
                left: 10.0,
                child: ListTile(
                  title: ElevatedButton(
                    child: buttonText,
                    style: buttonStyle,
                    onPressed: onButtonPressed != null
                        ? onButtonPressed
                        : () {
                            Navigator.pop(context);
                          },
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else if (items != null) {
      return Scaffold(
        backgroundColor:
            backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: Stack(
            fit: StackFit.loose,
            children: <Widget>[
              Positioned(
                top: 10.0,
                left: 0.0,
                right: 0.0,
                child: title,
              ),
              Positioned(
                left: 0.0,
                right: 0.0,
                top: 50.0,
                bottom: 80.0,
                child: ListView(
                  children: items!
                      .map(
                        (ListTile item) => ListTile(
                          title: item.title,
                          subtitle: item.subtitle,
                          leading: item.leading,
                          trailing: item.trailing,
                          onTap: item.onTap,
                          onLongPress: item.onLongPress,
                        ),
                      )
                      .toList(),
                ),
              ),
              Positioned(
                bottom: 5.0,
                right: 10.0,
                left: 10.0,
                child: ListTile(
                  title: ElevatedButton(
                    child: buttonText,
                    style: buttonStyle,
                    onPressed: onButtonPressed != null
                        ? onButtonPressed
                        : () => Navigator.pop(context),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Container();
  }

  Widget _buildIOS(BuildContext context) {
    Widget? child;
    if (changelog) {
      child = ChangeLogView(
        changes: changes,
        path: path,
        onTapLink: onTapLink,
      );
    } else if (items != null) {
      child = Material(
        child: ListView(
          children: items!,
        ),
      );
    }
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: title,
      ),
      child: SafeArea(
        child: child ?? Container(),
      ),
    );
  }
}

class ChangeLogView extends StatefulWidget {
  const ChangeLogView({
    this.onTapLink,
    this.path,
    this.changes,
  });
  final String? changes;
  final String? path;
  final MarkdownTapLinkCallback? onTapLink;
  @override
  _ChangeLogViewState createState() => _ChangeLogViewState();
}

class _ChangeLogViewState extends State<ChangeLogView> {
  String? _changelog;

  @override
  void initState() {
    if (widget.changes == null) {
      rootBundle.loadString(widget.path ?? "CHANGELOG.md").then((data) {
        setState(() {
          _changelog = data;
        });
      });
    } else {
      setState(() {
        _changelog = widget.changes;
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_changelog == null) {
      if (Platform.isIOS) {
        return Center(child: CupertinoActivityIndicator());
      } else {
        return Center(child: CircularProgressIndicator());
      }
    }
    return Markdown(data: _changelog!, onTapLink: widget.onTapLink);
  }
}
