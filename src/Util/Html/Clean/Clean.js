export const _untag = isWAll => wTags => isBAll => bTags => replaceWithSpace => str => {
    const wSet = new Set(wTags.map(t => t.toLowerCase()));
    const bSet = new Set(bTags.map(t => t.toLowerCase()));

    return str.replace(/<\/?([a-zA-Z0-9:-]+)[^>]*>/g, (match, tagName) => {
        const t = tagName.toLowerCase();
        const isWhitelisted = isWAll || wSet.has(t);
        const isBlacklistedInWhitelist = isBAll || bSet.has(t);

        if (isWhitelisted && !isBlacklistedInWhitelist) {
            return match;
        }
        return replaceWithSpace ? " " : "";
    });
};
