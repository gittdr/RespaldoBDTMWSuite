SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricResNowPages] (@MenuSectionSN int)
AS

	IF @MenuSectionSN <> -1
		SELECT RNMS.Sort, RNMS.SN, RNMS.Caption AS MenuCaption, RNP.*
		FROM ResNowPage RNP Join ResNowMenuSection RNMS on RNP.MenuSectionSN = RNMS.SN
		WHERE RNMS.Active = 1 AND MenuSectionSN = @MenuSectionSN
		ORDER BY RNMS.Sort, RNMS.SN, RNP.Sort

	ELSE
		SELECT RNMS.Sort, RNMS.SN, RNMS.Caption AS MenuCaption, RNP.*
		FROM ResNowPage RNP Join ResNowMenuSection RNMS on RNP.MenuSectionSN = RNMS.SN
		WHERE RNMS.Active = 1
		ORDER BY RNMS.Sort, RNMS.SN, RNP.Sort
GO
GRANT EXECUTE ON  [dbo].[MetricResNowPages] TO [public]
GO
