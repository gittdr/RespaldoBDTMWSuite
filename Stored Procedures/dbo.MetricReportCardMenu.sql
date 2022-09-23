SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricReportCardMenu] 
(
	@MenuCaption varchar(255) = 'Standard metrics', @ResNowPageSN int = 0
)

AS
	SET NOCOUNT ON

	DECLARE @t TABLE (MainCaption varchar(50), Caption varchar(50), sort int, ItemCaption varchar(80), 
					ItemSort int, parent varchar(30), MetricCode varchar(200), CategoryItemSort int )

	DECLARE @tbl TABLE (MainCaption varchar(50), Caption varchar(50), sort int, ItemCaption varchar(80), 
					ItemSort int, parent varchar(30), MetricCode varchar(200), CategoryItemSort int )

	DECLARE @ResNowMenuSectionSN int
	IF @ResNowPageSN > 0 
	BEGIN
		SELECT @ResNowMenuSectionSN = ReportCardMenuSN FROM resnowpage WHERE sn = @ResNowPageSN
	END
	ELSE -- Should never hit this code unless SP is applied without updating ASP pages.
	BEGIN
		SELECT TOP 1 @ResNowMenuSectionSN = sn FROM resnowmenusection WHERE Caption = @MenuCaption
	END

	INSERT INTO @t (MainCaption, Caption, sort, ItemCaption, ItemSort, parent, MetricCode, CategoryItemSort)
	SELECT DISTINCT 
				CASE 	WHEN ISNULL(ParentCaption, '') > '' THEN t3.ParentCaption 
						WHEN ISNULL(Parent, '') > '' THEN (SELECT CASE WHEN ISNULL(ParentCaption, '') > '' THEN ParentCaption ELSE CategoryCode END FROM metriccategory WHERE categorycode = t3.Parent) 
						ELSE t3.CategoryCode END AS MainCaption, 
				t3.Caption, 
				t3.sort, 
				t2.Caption As ItemCaption, 
				t2.Sort As ItemSort , 
				t3.parent, 
				t2.MetricCode,
				t1.sort AS CategoryItemSort /*,
				t5.sort,
				t5.caption,
				t5.sn */
	FROM metriccategoryitems t1 (NOLOCK) 
		JOIN metricitem t2 (NOLOCK) ON t1.MetricCode = t2.MetricCode 
	    JOIN metriccategory t3 (NOLOCK) ON t1.CategoryCode = t3.CategoryCode 
		JOIN ResNowPage t5 (NOLOCK) ON t5.CategoryCode = t3.CategoryCode
		JOIN ResNowMenuSection t4 (NOLOCK) ON t5.MenuSectionSN = t4.SN
	WHERE t1.Active = 1 
		AND t3.Active = 1 
		AND t2.Active = 1 
		AND t2.IncludeOnReportCardYN = 'Y' 
		AND ( t3.sn IN (SELECT MetricCategorySN FROM MetricPermission 
							WHERE GroupSn = (SELECT sn FROM MetricGroup WHERE GroupName = 'public')) 
								--OR t3.sn IN (SELECT tt1.sn FROM MetricUser tt1, MetricGroupUsers tt2, MetricGroup tt3, MetricPermission tt4 
								OR t3.sn IN (SELECT tt4.MetricCategorySN FROM MetricUser tt1, MetricGroupUsers tt2, MetricGroup tt3, MetricPermission tt4

										WHERE tt1.sn = tt2.UserSN AND tt2.GroupSn = tt3.sn AND tt3.sn = tt4.GroupSn 
											AND tt4.MetricCategorySN = t3.sn ) ) 
		AND t4.sn = @ResNowMenuSectionSN
	--ORDER BY t5.sort, t5.sn, MainCaption, t3.sort, t2.sort 
	ORDER BY MainCaption, t3.sort, t2.sort 

	INSERT INTO @tbl (MainCaption, Caption, sort, ItemCaption, ItemSort, parent, MetricCode, CategoryItemSort)
	SELECT MainCaption, Caption, sort, ItemCaption, ItemSort, parent, MetricCode, CategoryItemSort FROM @t

	INSERT INTO @tbl (MainCaption, Caption, sort, ItemCaption, ItemSort, parent, MetricCode, CategoryItemSort)
	SELECT DISTINCT 
				t3.MainCaption, /* CASE 	WHEN ISNULL(ParentCaption, '') > '' THEN t3.ParentCaption 
						WHEN ISNULL(Parent, '') > '' THEN (SELECT CASE WHEN ISNULL(ParentCaption, '') > '' THEN ParentCaption ELSE CategoryCode END FROM metriccategory WHERE categorycode = t3.Parent) 
						ELSE t3.CategoryCode END AS MainCaption, */
				t3.Caption, 
				t2.sort, 
				t2.Caption As ItemCaption, 
				t2.Sort As ItemSort , 
				t3.parent, 
				t2.MetricCode,
				t3.CategoryItemSort 
	FROM metricitem t2 (NOLOCK) INNER JOIN @t t3 ON LEFT(t2.metriccode, LEN(t3.metriccode)) = t3.metriccode 
	WHERE t2.Active = 1 AND t2.IncludeOnReportCardYN = 'Y' AND ISNULL(t2.LayerSN, 0) > 0 
		AND t2.metriccode <> t3.metriccode

/*	FROM metricitem t2 (NOLOCK) -- INNER JOIN @t t3 ON t2.metriccode =  Left(t3.metriccode, LEN(t2.metriccode))
	WHERE t2.Active = 1 AND t2.IncludeOnReportCardYN = 'Y' AND ISNULL(t2.LayerSN, 0) > 0 AND
		EXISTS(SELECT MetricCode FROM @tbl tInner WHERE Left(t2.MetricCode, LEN(tInner.MetricCode) + 1) = tInner.MetricCode + '_')
*/

	SELECT * FROM @tbl ORDER BY sort, CategoryItemSort

GO
GRANT EXECUTE ON  [dbo].[MetricReportCardMenu] TO [public]
GO
