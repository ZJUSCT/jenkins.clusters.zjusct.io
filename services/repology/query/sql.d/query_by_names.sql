-- @param packagenames
-- @param repos
-- @returns array of dicts
SELECT DISTINCT
    repo,
    effname AS project_name,
    CASE 
        WHEN visiblename = ANY(%(packagenames)s) THEN visiblename
        WHEN binname = ANY(%(packagenames)s) THEN binname
        ELSE (
            SELECT b FROM unnest(binnames) AS b
            WHERE b = ANY(%(packagenames)s)
            LIMIT 1
        )
    END AS pkg_name
FROM
    packages
WHERE
    (
        visiblename = ANY(%(packagenames)s) OR
        binname = ANY(%(packagenames)s) OR
        EXISTS (
            SELECT 1
            FROM unnest(binnames) AS b
            WHERE b = ANY(%(packagenames)s)
        )
    )
    AND repo = ANY(%(repos)s)
