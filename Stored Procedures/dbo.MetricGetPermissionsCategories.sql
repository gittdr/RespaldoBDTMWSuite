SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricGetPermissionsCategories] (@GroupSN int, @MembersOption VARCHAR(1) )
AS
	SET NOCOUNT ON

	If @MembersOption = 'B'
		SELECT t1.sn As mgpSN, t1.GroupSN, t2.CategoryCode, t2.Caption, t2.Active, t2.sn AS MetricCategorySN
		FROM MetricCategory t2 LEFT OUTER JOIN MetricPermission t1   
			ON t2.sn = t1.MetricCategorySN AND t1.GroupSN = @GroupSN AND t1.MetricCategorySN > 0  
		ORDER BY t2.CategoryCode
   ELSE IF @MembersOption = 'Y'
		SELECT t1.sn As mgpSN, t1.GroupSN, t2.CategoryCode, t2.Caption, t2.Active, t2.sn AS MetricCategorySN   
		FROM MetricCategory t2 INNER JOIN MetricPermission t1   
			ON t2.sn = t1.MetricCategorySN AND t1.GroupSN = @GroupSN AND t1.MetricCategorySN > 0  
	  ORDER BY t2.CategoryCode 
   ELSE IF @MembersOption = 'N'
		SELECT 'NEW' As mgpSN, t2.CategoryCode, t2.Caption, t2.Active, t2.sn AS MetricCategorySN  
		FROM MetricCategory t2  
		WHERE NOT EXISTS(SELECT sn FROM MetricPermission t1 WHERE t1.MetricCategorySN = t2.sn AND t1.GroupSN = @GroupSN AND t1.MetricCategorySN <> 0)  
		ORDER BY t2.CategoryCode 

GO
GRANT EXECUTE ON  [dbo].[MetricGetPermissionsCategories] TO [public]
GO
