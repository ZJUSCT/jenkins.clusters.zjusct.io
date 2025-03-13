-- @param visiblenames
-- @param repos
-- @returns array of dicts
SELECT DISTINCT
    repo,
    visiblename,
    effname,
    binname,
    binnames
FROM
    packages
WHERE
    (
        binname = ANY(%(visiblenames)s) OR
        EXISTS (
            SELECT 1
            FROM unnest(binnames) AS b
            WHERE b = ANY(%(visiblenames)s)
        )
    )
    AND repo = ANY(%(repos)s)
ORDER BY
    effname,
    repo,
    visiblename
