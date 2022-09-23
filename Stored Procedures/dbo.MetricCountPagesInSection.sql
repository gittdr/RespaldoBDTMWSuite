SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricCountPagesInSection] (@sn int )
AS
	SET NOCOUNT ON

	SELECT count(*) AS CountRecords
    FROM resnowmenusection t1 INNER JOIN resnowpage t2 ON t1.sn = t2.MenuSectionSN 
    WHERE t1.sn = @sn AND t2.Active = 1
GO
GRANT EXECUTE ON  [dbo].[MetricCountPagesInSection] TO [public]
GO
