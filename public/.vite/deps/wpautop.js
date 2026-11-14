import { t as __commonJSMin } from "./chunk-olfrzTEO.js";
//#region run/bak/js/node_modules/wpautop/lib/wpautop.js
var require_wpautop = /* @__PURE__ */ __commonJSMin(((exports, module) => {
	/**
	* JavaScript port of wpautop
	* @see: http://develop.svn.wordpress.org/trunk/src/wp-includes/formatting.php
	*/
	/**
	* Newline preservation help function for wpautop
	*
	* @since 3.1.0
	* @access private
	*
	* @param array $matches preg_replace_callback matches array
	* @return string
	*/
	function _autop_newline_preservation_helper(matches) {
		return matches[0].replace("\n", "<WPPreserveNewline />");
	}
	/**
	* Replaces double line-breaks with paragraph elements.
	*
	* A group of regex replaces used to identify text formatted with newlines and
	* replace double line-breaks with HTML paragraph tags. The remaining
	* line-breaks after conversion become <<br />> tags, unless $br is set to '0'
	* or 'false'.
	*
	* @since 0.71
	*
	* @param string pee The text which has to be formatted.
	* @param bool br Optional. If set, this will convert all remaining line-breaks after paragraphing. Default true.
	* @return string Text which has been converted into correct paragraph tags.
	*/
	function wpautop(pee, br) {
		if (typeof br === "undefined") br = true;
		var pre_tags = /* @__PURE__ */ new Map();
		if (pee.trim() === "") return "";
		pee = pee + "\n";
		if (pee.indexOf("<pre") > -1) {
			var pee_parts = pee.split("</pre>");
			var last_pee = pee_parts.pop();
			pee = "";
			pee_parts.forEach(function(pee_part, index) {
				var start = pee_part.indexOf("<pre");
				if (start === -1) {
					pee += pee_part;
					return;
				}
				var name = "<pre wp-pre-tag-" + index + "></pre>";
				pre_tags[name] = pee_part.substr(start) + "</pre>";
				pee += pee_part.substr(0, start) + name;
			});
			pee += last_pee;
		}
		pee = pee.replace(/<br \/>\s*<br \/>/, "\n\n");
		var allblocks = "(?:table|thead|tfoot|caption|col|colgroup|tbody|tr|td|th|div|dl|dd|dt|ul|ol|li|pre|form|map|area|blockquote|address|math|style|p|h[1-6]|hr|fieldset|legend|section|article|aside|hgroup|header|footer|nav|figure|figcaption|details|menu|summary)";
		pee = pee.replace(new RegExp("(<" + allblocks + "[^>]*>)", "gmi"), "\n$1");
		pee = pee.replace(new RegExp("(</" + allblocks + ">)", "gmi"), "$1\n\n");
		pee = pee.replace(/\r\n|\r/, "\n");
		if (pee.indexOf("<option") > -1) {
			pee = pee.replace(/\s*<option'/gim, "<option");
			pee = pee.replace(/<\/option>\s*/gim, "</option>");
		}
		if (pee.indexOf("</object>") > -1) {
			pee = pee.replace(/(<object[^>]*>)\s*/gim, "$1");
			pee = pee.replace(/\s*<\/object>/gim, "</object>");
			pee = pee.replace(/\s*(<\/?(?:param|embed)[^>]*>)\s*/gim, "$1");
		}
		if (pee.indexOf("<source") > -1 || pee.indexOf("<track") > -1) {
			pee = pee.replace(/([<\[](?:audio|video)[^>\]]*[>\]])\s*/gim, "$1");
			pee = pee.replace(/\s*([<\[]\/(?:audio|video)[>\]])/gim, "$1");
			pee = pee.replace(/\s*(<(?:source|track)[^>]*>)\s*/gim, "$1");
		}
		pee = pee.replace(/\n\n+/gim, "\n\n");
		var pees = pee.split(/\n\s*\n/);
		pee = "";
		pees.forEach(function(tinkle) {
			pee += "<p>" + tinkle.replace(/^\s+|\s+$/g, "") + "</p>\n";
		});
		pee = pee.replace(/<p>\s*<\/p>/gim, "");
		pee = pee.replace(/<p>([^<]+)<\/(div|address|form)>/gim, "<p>$1</p></$2>");
		pee = pee.replace(new RegExp("<p>s*(</?" + allblocks + "[^>]*>)s*</p>", "gmi"), "$1", pee);
		pee = pee.replace(/<p>(<li.+?)<\/p>/gim, "$1");
		pee = pee.replace(/<p><blockquote([^>]*)>/gim, "<blockquote$1><p>");
		pee = pee.replace(/<\/blockquote><\/p>/gim, "</p></blockquote>");
		pee = pee.replace(new RegExp("<p>s*(</?" + allblocks + "[^>]*>)", "gmi"), "$1");
		pee = pee.replace(new RegExp("(</?" + allblocks + "[^>]*>)s*</p>", "gmi"), "$1");
		if (br) {
			pee = pee.replace(/<(script|style)(?:.|\n)*?<\/\\1>/gim, _autop_newline_preservation_helper);
			pee = pee.replace(/(<br \/>)?\s*\n/gim, "<br />\n");
			pee = pee.replace("<WPPreserveNewline />", "\n");
		}
		pee = pee.replace(new RegExp("(</?" + allblocks + "[^>]*>)s*<br />", "gmi"), "$1");
		pee = pee.replace(/<br \/>(\s*<\/?(?:p|li|div|dl|dd|dt|th|pre|td|ul|ol)[^>]*>)/gim, "$1");
		pee = pee.replace(/\n<\/p>$/gim, "</p>");
		if (Object.keys(pre_tags).length) pee = pee.replace(new RegExp(Object.keys(pre_tags).join("|"), "gi"), function(matched) {
			return pre_tags[matched];
		});
		return pee;
	}
	module.exports = wpautop;
}));
//#endregion
export default require_wpautop();

//# sourceMappingURL=wpautop.js.map