import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';
import 'package:awesome_chewie/awesome_chewie.dart';
import 'package:html_unescape/html_unescape.dart';

typedef LanguageDetector = String Function(String code);

class HtmlUtil {
  static LanguageDetector detectLanguage = (String code) {
    if (RegExp(r'\bvoid\s+main\s*\(\)').hasMatch(code) ||
        // RegExp(r"import\s+['\"]dart").hasMatch(code) ||
        RegExp(r'@override').hasMatch(code) ||
        RegExp(r'final\s+\w+').hasMatch(code)) {
      return 'Dart';
    } else if (RegExp(r'\bpackage\s+\w+').hasMatch(code) ||
        // RegExp(r'\bimport\s+["\']\w+["\']').hasMatch(code) ||
        RegExp(r'\bfunc\s+\w+\s*\(').hasMatch(code) ||
        RegExp(r'fmt\.Println\s*\(').hasMatch(code)) {
      return 'Go';
    } else if (RegExp(r'\bdef\s+\w+\s*\(').hasMatch(code) ||
        RegExp(r'\bprint\s*\(').hasMatch(code) ||
        RegExp(r'import\s+\w+').hasMatch(code) ||
        RegExp(r'#[^\n]*').hasMatch(code)) {
      return 'Python';
    } else if (RegExp(r'console\.log\s*\(').hasMatch(code) ||
        RegExp(r'function\s+\w+\s*\(').hasMatch(code) ||
        RegExp(r'const\s+\w+\s*=').hasMatch(code) ||
        RegExp(r'let\s+\w+\s*=').hasMatch(code) ||
        RegExp(r'//[^\n]*').hasMatch(code)) {
      return 'JavaScript';
    } else if (RegExp(r'public\s+class\s+\w+').hasMatch(code) ||
        RegExp(r'System\.out\.println\s*\(').hasMatch(code) ||
        RegExp(r'public\s+(static\s+)?void\s+main\s*\(').hasMatch(code) ||
        RegExp(r'import\s+java\.').hasMatch(code)) {
      return 'Java';
    } else if (RegExp(r'#include\s+<[^>]+>').hasMatch(code) ||
        RegExp(r'\bint\s+main\s*\(').hasMatch(code) ||
        RegExp(r'printf\s*\(').hasMatch(code) ||
        RegExp(r'//[^\n]*').hasMatch(code) ||
        RegExp(r'/\*[\s\S]*?\*/').hasMatch(code)) {
      return 'C/C++';
    } else if (RegExp(r'<\?php').hasMatch(code) ||
        // RegExp(r'echo\s+["\'].*["\'];').hasMatch(code) ||
        RegExp(r'\bfunction\s+\w+\s*\(').hasMatch(code) ||
        RegExp(r'\$\w+').hasMatch(code)) {
      return 'PHP';
    } else if (RegExp(r'<html\s*>').hasMatch(code) ||
        RegExp(r'<body\s*>').hasMatch(code) ||
        RegExp(r'<head\s*>').hasMatch(code) ||
        RegExp(r'<!DOCTYPE\s+html>').hasMatch(code)) {
      return 'HTML';
    } else if (RegExp(r'\.\w+\s*{').hasMatch(code) ||
        RegExp(r'#\w+\s*{').hasMatch(code) ||
        RegExp(r'\bcolor\s*:\s*').hasMatch(code) ||
        RegExp(r'\bfont-size\s*:\s*').hasMatch(code)) {
      return 'CSS';
    } else if (RegExp(r'SELECT\s+.+\s+FROM').hasMatch(code) ||
        RegExp(r'INSERT\s+INTO').hasMatch(code) ||
        RegExp(r'UPDATE\s+\w+\s+SET').hasMatch(code) ||
        RegExp(r'DELETE\s+FROM').hasMatch(code) ||
        RegExp(r'CREATE\s+TABLE').hasMatch(code)) {
      return 'SQL';
    } else if (RegExp(r'^#!/bin/bash').hasMatch(code) ||
        // RegExp(r'\becho\s+["\'].*["\']').hasMatch(code) ||
        RegExp(r'\bif\s*\[\s*.*\s*\]').hasMatch(code) ||
        RegExp(r'\bfor\s+\w+\s+in').hasMatch(code)) {
      return 'Shell';
    } else if (RegExp(r'^<\?xml').hasMatch(code) ||
        RegExp(r'<[a-zA-Z0-9]+[^>]*>').hasMatch(code)) {
      return 'XML';
    }
    return 'Plain Text';
  };

  static List<String> extractTitles(
    String html, {
    int maxLevel = 5,
  }) {
    List<String> titles = [];
    dom.Document document = parse(html);
    document.querySelectorAll('h1, h2, h3, h4, h5, h6').forEach((element) {
      String tagName = element.localName!;
      int level = int.tryParse(tagName.substring(1)) ?? 0;
      if (level <= 0 || level > maxLevel) return;
      titles.add(element.text.trim());
    });
    return titles;
  }

  static String unscape(String html) {
    final unescape = HtmlUnescape();
    return unescape.convert(html);
  }

  static List<Anchor> extractAnchors(
    String title,
    String html, {
    bool addTitleAnchor = true,
    int maxLevel = 5,
  }) {
    List<Anchor> titles = [];
    dom.Document document = parse(html);

    document.querySelectorAll('h1, h2, h3, h4, h5, h6').forEach((element) {
      String tagName = element.localName!;
      int level = int.tryParse(tagName.substring(1)) ?? 0;
      if (level <= 0 || level > maxLevel) return;

      String text = element.text.trim();
      AnchorType? anchorType;

      switch (tagName) {
        case 'h1':
          anchorType = AnchorType.h1;
          break;
        case 'h2':
          anchorType = AnchorType.h2;
          break;
        case 'h3':
          anchorType = AnchorType.h3;
          break;
        case 'h4':
          anchorType = AnchorType.h4;
          break;
        case 'h5':
          anchorType = AnchorType.h5;
          break;
        case 'h6':
          anchorType = AnchorType.h6;
          break;
      }

      if (anchorType != null) {
        titles.add(
          Anchor(anchorType, StringUtil.clearBlank(extractTextFromHtml(text))),
        );
      }
    });

    if (addTitleAnchor && titles.isNotEmpty) {
      titles.insert(
        0,
        Anchor(
            AnchorType.top, StringUtil.clearBlank(extractTextFromHtml(title))),
      );
    }

    return titles;
  }

  static String extractTextFromHtml(String html) {
    var document = parse(html);
    return document.body?.text ?? "";
  }

  static List<String> extractImagesFromHtml(String html) {
    var document = parse(html);
    var images = document.getElementsByTagName("img");
    return images
        .map((e) => e.attributes["src"] ?? e.attributes['data-src'] ?? '')
        .toList();
  }

  static String extractCodeFromPre(preElement) {
    final buffer = StringBuffer();

    for (var node in preElement.children) {
      if (node is dom.Element && node.localName == 'br') {
        buffer.write("\n");
      } else if (node is dom.Element) {
        buffer.write(_extractTextRecursively(node));
      } else if (node is dom.Text) {
        buffer.write(node.text);
      }
    }

    return buffer.toString();
  }

  static String _extractTextRecursively(dom.Node node) {
    if (node is dom.Text) return node.text;

    if (node is dom.Element) {
      return node.nodes.map(_extractTextRecursively).join('');
    }

    return '';
  }

  static String preProcessHtml(String html) {
    html = convertLatexToTexTags(html);
    html = convertBareUrlsToAnchorsWithDom(html);
    html = removeInlineStyles(html);
    return html;
  }

  static String removeInlineStyles(String html) {
    dom.Document document = parse(html);

    void removeStyles(dom.Node node) {
      if (node is dom.Element) {
        node.attributes.remove('style');
        for (var child in node.nodes) {
          removeStyles(child);
        }
      }
    }

    for (var element in document.body?.nodes ?? []) {
      removeStyles(element);
    }

    return document.body?.innerHtml ?? html;
  }

  static String convertBareUrlsToAnchorsWithDom(String html) {
    final document = parseFragment(html);

    void traverse(dom.Node node) {
      if (node.nodeType == dom.Node.TEXT_NODE) {
        final text = node.text!;
        final parent = node.parent;
        if (parent != null &&
            parent.localName != 'a' &&
            parent.localName != 'img' &&
            text.contains(RegExp(r'https?:\/\/'))) {
          final urlRegex = RegExp("(?<![\"'=])\\bhttps?:\\/\\/[^\\s<>\"'\\)]+");
          final newNodes = <dom.Node>[];
          int lastIndex = 0;

          for (final match in urlRegex.allMatches(text)) {
            final url = match.group(0)!;
            if (match.start > lastIndex) {
              newNodes.add(dom.Text(text.substring(lastIndex, match.start)));
            }

            final anchor = dom.Element.tag('a')
              ..attributes['href'] = url
              ..attributes['target'] = '_blank'
              ..attributes['rel'] = 'noopener noreferrer'
              ..text = url;

            newNodes.add(anchor);
            lastIndex = match.end;
          }

          if (lastIndex < text.length) {
            newNodes.add(dom.Text(text.substring(lastIndex)));
          }

          for (var newNode in newNodes) {
            node.parent!.insertBefore(newNode, node);
          }
          node.remove();
        }
      } else {
        for (final child in node.nodes.toList()) {
          traverse(child);
        }
      }
    }

    traverse(document);

    return document.outerHtml;
  }

  static String convertLatexToTexTags(String input) {
    String result = input;

    result = result.replaceAllMapped(
      RegExp(r'\$\$([\s\S]+?)\$\$', multiLine: true),
      (match) => '<tex>${match[1]}</tex>',
    );
    result = result.replaceAllMapped(
      RegExp(r'\\\[(.*?)\\\]', dotAll: true),
      (match) => '<tex>${match[1]}</tex>',
    );

    result = result.replaceAllMapped(
      RegExp(r'(?<!\$)\$(?!\$)(.+?)(?<!\$)\$(?!\$)', dotAll: true),
      (match) => '<inlinetex>${match[1]}</inlinetex>',
    );
    result = result.replaceAllMapped(
      RegExp(r'\\\((.*?)\\\)', dotAll: true),
      (match) => '<inlinetex>${match[1]}</inlinetex>',
    );

    return result;
  }

  static String convertHtmlToXhtml(String htmlSource) {
    final document = parse(htmlSource);

    void enforceXhtml(dom.Node node) {
      if (node is dom.Element) {
        final attrs = Map<String, String>.from(node.attributes);
        node.attributes.clear();
        attrs.forEach((key, value) {
          node.attributes[key.toLowerCase()] = value;
        });

        for (final child in node.nodes) {
          enforceXhtml(child);
        }
      }
    }

    enforceXhtml(document.documentElement!);

    return document.outerHtml.replaceAllMapped(
      RegExp(r'<(br|img|hr|input)([^>]*)>'),
      (match) => '<${match[1] ?? ''}${match[2] ?? ''} />',
    );
  }

  static const int ATTRIBUTE_NODE = 2;
  static const int CDATA_SECTION_NODE = 4;
  static const int COMMENT_NODE = 8;
  static const int DOCUMENT_FRAGMENT_NODE = 11;
  static const int DOCUMENT_NODE = 9;
  static const int DOCUMENT_TYPE_NODE = 10;
  static const int ELEMENT_NODE = 1;
  static const int ENTITY_NODE = 6;
  static const int ENTITY_REFERENCE_NODE = 5;
  static const int NOTATION_NODE = 12;
  static const int PROCESSING_INSTRUCTION_NODE = 7;
  static const int TEXT_NODE = 3;

  static String getNodeType(int type) {
    switch (type) {
      case ATTRIBUTE_NODE:
        return "ATTRIBUTE_NODE";
      case CDATA_SECTION_NODE:
        return "CDATA_SECTION_NODE";
      case COMMENT_NODE:
        return "COMMENT_NODE";
      case DOCUMENT_FRAGMENT_NODE:
        return "DOCUMENT_FRAGMENT_NODE";
      case DOCUMENT_NODE:
        return "DOCUMENT_NODE";
      case DOCUMENT_TYPE_NODE:
        return "DOCUMENT_TYPE_NODE";
      case ELEMENT_NODE:
        return "ELEMENT_NODE";
      case ENTITY_NODE:
        return "ENTITY_NODE";
      case ENTITY_REFERENCE_NODE:
        return "ENTITY_REFERENCE_NODE";
      case NOTATION_NODE:
        return "NOTATION_NODE";
      case PROCESSING_INSTRUCTION_NODE:
        return "PROCESSING_INSTRUCTION_NODE";
      case TEXT_NODE:
        return "TEXT_NODE";
      default:
        return "UNKNOWN";
    }
  }

  static String highlightHtmlText(String html, int startOffset, int endOffset) {
    final doc = parseFragment(html);
    int globalOffset = 0;

    void processNode(dom.Node node, [dom.Node? parent]) {
      if (node.nodeType == dom.Node.TEXT_NODE) {
        final text = StringUtil.clearBreak(node.text!);
        if (text.isEmpty) return;
        final nodeStart = globalOffset;
        final nodeEnd = globalOffset + text.length;

        globalOffset = nodeEnd;

        // print("Text Node: $text");

        if (endOffset <= nodeStart || startOffset >= nodeEnd) return;

        final localStart = (startOffset - nodeStart).clamp(0, text.length);
        final localEnd = (endOffset - nodeStart).clamp(0, text.length);

        final before = text.substring(0, localStart);
        final highlight = text.substring(localStart, localEnd);
        final after = text.substring(localEnd);

        final newNodes = <dom.Node>[
          if (before.isNotEmpty) dom.Text(before),
          if (highlight.isNotEmpty)
            dom.Element.tag('custom-highlight')..append(dom.Text(highlight)),
          if (after.isNotEmpty) dom.Text(after),
        ];

        final actualParent = node.parent ?? parent;
        if (actualParent != null) {
          final index = actualParent.nodes.indexOf(node);
          actualParent.nodes.removeAt(index);
          actualParent.nodes.insertAll(index, newNodes);
        }
      } else if (node.nodeType == dom.Node.ELEMENT_NODE) {
        for (var child in node.nodes.toList()) {
          processNode(child, node);
        }
      }
    }

    for (var node in doc.nodes.toList()) {
      processNode(node);
    }

    return doc.outerHtml;
  }
}
