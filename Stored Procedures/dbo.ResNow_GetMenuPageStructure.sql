SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[ResNow_GetMenuPageStructure] 
(
	@UserSN int
)
AS
	SET NOCOUNT ON

	SET NOCOUNT ON 
	DECLARE @PublicGroupSN int

	SELECT @PublicGroupSN = sn FROM MetricGroup WHERE GroupName = 'public'

			SELECT t1.sn AS MenuSN, 
				t1.sort AS MenuSort, 
				t1.Caption AS MenuCaption, 
				t1.CaptionFull AS MenuCaptionFull, 
				t1.MenuSystem, 
				t1.CustomProcess as MenuCustomProcess, 
				t1.CustomPageTable as MenuCustomPageTable,
				CASE WHEN t2.sn IS NULL THEN '' ELSE CONVERT(varchar(10), t2.sn) END AS PageSN, 
				t2.sort as PageSort,
				t2.caption AS PageCaption, 
				t2.CaptionFull AS PageCaptionFull,  		
				t2.PagePassword,
				IsNull(t2.PageURL,'') as PageURL, 
				CASE WHEN t2.ShowTime IS NULL THEN '' ELSE CONVERT(varchar(10), t2.ShowTime) END AS PageShowTime
			FROM ResNowMenuSection t1 JOIN ResNowPage t2 
		          ON t1.sn = t2.MenuSectionSN 
			WHERE 
				-- Page and Section need to be ACTIVE.
				t1.Active = 1 AND ISNULL(t2.Active, 1) = 1 

				-- Section EITHER needs to be part of PUBLIC, OR user needs to be in a group that has rights.
				AND (
					EXISTS(SELECT ResNowSectionSN FROM MetricPermission WHERE GroupSn = @PublicGroupSN AND ResNowSectionSN = t1.sn )
                  OR
				 	EXISTS (SELECT tt1.sn 
								FROM (MetricUser tt1 INNER JOIN MetricGroupUsers tt2 ON tt1.sn = tt2.UserSN 
									INNER JOIN MetricGroup tt3 ON tt2.GroupSn = tt3.sn)
									INNER JOIN MetricPermission tt4 ON tt3.sn = tt4.GroupSn AND tt4.ResNowSectionSN = t1.sn
								WHERE tt1.sn = @UserSN
								)
				)

				AND (  --*** Te page category is 0.
						IsNull(t2.MetricCategorySN,0) = 0
					OR --*** Category has PUBLIC RIGHTS.
						EXISTS (SELECT MetricCategorySN FROM MetricPermission WHERE GroupSn = @PublicGroupSN AND MetricCategorySN = t2.MetricCategorySN)
					OR --*** Category has RIGHTS.
					 	EXISTS (SELECT tt1.sn 
									FROM (MetricUser tt1 INNER JOIN MetricGroupUsers tt2 ON tt1.sn = tt2.UserSN 
										INNER JOIN MetricGroup tt3 ON tt2.GroupSn = tt3.sn) 
										INNER JOIN MetricPermission tt4 ON tt3.sn = tt4.GroupSn AND tt4.MetricCategorySN = t2.MetricCategorySN
										WHERE tt1.sn = @UserSN
									)
					)

			ORDER BY t1.sort, t1.sn, t2.sort

	SET NOCOUNT OFF
GO
GRANT EXECUTE ON  [dbo].[ResNow_GetMenuPageStructure] TO [public]
GO
