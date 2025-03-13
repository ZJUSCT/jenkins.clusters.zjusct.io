-- @param visiblenames
-- @param repos
-- @returns array of dicts
SELECT DISTINCT
    repo,
    visiblename,
    effname
FROM
    packages
WHERE
    visiblename = ANY(%(visiblenames)s)
    AND repo = ANY(%(repos)s)
ORDER BY
    effname,
    repo,
    visiblename
