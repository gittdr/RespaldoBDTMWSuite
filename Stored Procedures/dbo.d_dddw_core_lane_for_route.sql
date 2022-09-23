SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO



CREATE PROCEDURE [dbo].[d_dddw_core_lane_for_route] (@origin_type int,
											@origin_value varchar(50),
											@dest_type int,
											@dest_value varchar(50)
				)


AS
	DECLARE @Rowcount int

	CREATE TABLE #Resultset(
		sortorder	int			NOT NULL,
		laneid		int			NOT NULL,
		lanecode	varchar(15) NOT NULL,
		lanename	varchar(50) NULL
	)
	
	

	INSERT INTO #Resultset
	SELECT 1, laneid, lanecode, lanename
	FROM core_lane cl
	WHERE EXISTS(SELECT * 
					FROM core_lanelocation cllinner
					WHERE cllinner.laneid = cl.laneid
						AND cllinner.IsOrigin = 1
						AND cllinner.type = @origin_type
						AND ((@origin_type = 6 AND isnull(cllinner.countrycode, '') = isnull(@origin_value, ''))
							OR (@origin_type = 5 AND isnull(cllinner.stateabbr, '') = isnull(@origin_value, ''))
							OR (@origin_type = 4 AND isnull(cllinner.county, '') = isnull(@origin_value, ''))
							OR (@origin_type = 2 AND isnull(cllinner.cityname, '') = isnull(@origin_value, ''))
							OR (@origin_type = 3 AND isnull(cllinner.zippart, '') = isnull(@origin_value, ''))
							OR (@origin_type = 1 AND isnull(cllinner.companyid, '') = isnull(@origin_value, ''))
						)
					)
			AND EXISTS(SELECT *
						FROM core_lanelocation cllinner
						WHERE cllinner.laneid = cl.laneid
							AND cllinner.IsOrigin = 2
							AND cllinner.type = @dest_type
							AND ((@dest_type = 6 AND isnull(cllinner.countrycode, '') = isnull(@dest_value, ''))
								OR (@dest_type = 5 AND isnull(cllinner.stateabbr, '') = isnull(@dest_value, ''))
								OR (@dest_type = 4 AND isnull(cllinner.county, '') = isnull(@dest_value, ''))
								OR (@dest_type = 2 AND isnull(cllinner.cityname, '') = isnull(@dest_value, ''))
								OR (@dest_type = 3 AND isnull(cllinner.zippart, '') = isnull(@dest_value, ''))
								OR (@dest_type = 1 AND isnull(cllinner.companyid, '') = isnull(@dest_value, ''))
							)
						)


	SELECT @Rowcount = count(*)
	FROM #Resultset
	
	IF @Rowcount > 1 BEGIN
		INSERT #Resultset
		SELECT 0, 0, '(Select Lane)', '(Select Lane)'
	END

	INSERT #Resultset
	SELECT 2, -1 , '(New Lane)', '(New Lane)'

	

SELECT 
		laneid,
		lanecode,
		lanename
FROM #Resultset
ORDER BY sortorder, lanecode
	
GO
GRANT EXECUTE ON  [dbo].[d_dddw_core_lane_for_route] TO [public]
GO
