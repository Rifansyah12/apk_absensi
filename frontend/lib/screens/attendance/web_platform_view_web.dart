// web_platform_view_web.dart
import 'dart:html';
import 'dart:js' as js;

// akses platformViewRegistry di web
void registerViewFactory(
  String viewTypeId,
  HtmlElement Function(int) viewFactory,
) {
  // ignore: undefined_prefixed_name
  js.context.callMethod('registerViewFactory', [viewTypeId, viewFactory]);
}
