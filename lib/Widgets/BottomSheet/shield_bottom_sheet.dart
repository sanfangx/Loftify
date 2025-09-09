import 'package:awesome_chewie/awesome_chewie.dart';
import 'package:flutter/material.dart';
import 'package:loftify/Widgets/Item/item_builder.dart';

import '../../Utils/enums.dart';
import '../../l10n/l10n.dart';

class ShieldBottomSheet extends StatefulWidget {
  const ShieldBottomSheet({
    super.key,
    required this.tags,
    this.onShieldTag,
    this.onShieldContent,
    this.onShieldUser,
  });

  final Function(String tag)? onShieldTag;
  final Function()? onShieldContent;
  final Function()? onShieldUser;
  final List<String> tags;

  @override
  ShieldBottomSheetState createState() => ShieldBottomSheetState();
}

class ShieldBottomSheetState extends State<ShieldBottomSheet> {
  late List<String> tags;

  @override
  void initState() {
    super.initState();
    tags = widget.tags;
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      runAlignment: WrapAlignment.center,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 50),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: ChewieTheme.getBackground(context),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildHeader(),
              _buildButtons(),
              const MyDivider(horizontal: 12, vertical: 0),
              _buildFooter(),
            ],
          ),
        ),
      ],
    );
  }

  _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      alignment: Alignment.center,
      child: Text(
        appLocalizations.reduceRecommend,
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }

  _buildButtons() {
    return Container(
      padding: const EdgeInsets.only(left: 12, right: 12, top: 10, bottom: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Wrap(
            alignment: WrapAlignment.start,
            runAlignment: WrapAlignment.start,
            crossAxisAlignment: WrapCrossAlignment.start,
            spacing: 10,
            runSpacing: 10,
            children: tags.map((tag) {
              return MouseRegion(
                cursor: SystemMouseCursors.click,
                child: ItemBuilder.buildTagItem(
                  context,
                  tag,
                  TagType.normal,
                  fontWeightDelta: 2,
                  fontSizeDelta: 1,
                  jumpToTag: false,
                  color: Theme.of(context).textTheme.titleMedium?.color,
                  onTap: () {
                    widget.onShieldTag?.call(tag);
                  },
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 45,
            child: RoundIconTextButton(
              text: appLocalizations.uninterestedInContent,
              onPressed: widget.onShieldContent,
              fontSizeDelta: 2,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 45,
            child: RoundIconTextButton(
              text: appLocalizations.uninterestedInUser,
              onPressed: widget.onShieldUser,
              fontSizeDelta: 2,
            ),
          ),
        ],
      ),
    );
  }
}
