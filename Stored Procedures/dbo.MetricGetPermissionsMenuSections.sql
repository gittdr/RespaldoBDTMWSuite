SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricGetPermissionsMenuSections] (@GroupSN int, @MembersOption VARCHAR(1) )
AS

	SET NOCOUNT ON

	If @MembersOption = 'B'
		SELECT t1.sn As mgpSN, t1.GroupSN, t2.Caption, t2.CaptionFull, t2.Active, t2.sn AS ResNowSectionSN 
		FROM ResNowMenuSection t2 LEFT OUTER JOIN MetricPermission t1 
			ON t2.sn = t1.ResNowSectionSN AND t1.GroupSN = @GroupSN AND t1.ResNowSectionSN > 0 
		ORDER BY t2.Caption
	ELSE IF @MembersOption = 'Y'
		SELECT t1.sn As mgpSN, t1.GroupSN, t2.Caption, t2.CaptionFull, t2.Active, t2.sn AS ResNowSectionSN  
		FROM ResNowMenuSection t2 INNER JOIN MetricPermission t1  
			ON t2.sn = t1.ResNowSectionSN AND t1.GroupSN = @GroupSN AND t1.ResNowSectionSN > 0 
		ORDER BY t2.Caption
	ELSE IF @MembersOption = 'N'
		SELECT 'NEW' As mgpSN, t2.Caption, t2.CaptionFull, t2.Active, t2.sn AS ResNowSectionSN 
		FROM ResNowMenuSection t2
		WHERE NOT EXISTS(SELECT sn FROM MetricPermission t1 WHERE t1.ResNowSectionSN = t2.sn AND t1.GroupSN = @GroupSN AND t1.ResNowSectionSN <> 0) 
		ORDER BY t2.Caption
GO
GRANT EXECUTE ON  [dbo].[MetricGetPermissionsMenuSections] TO [public]
GO
