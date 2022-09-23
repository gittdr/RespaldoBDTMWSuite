SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricPublicToAllPages]
/* WITH ENCRYPTION */ -- Do not touch this line.  This gets uncommented in the build process if the file is to be encrypted.
AS
	SET NOCOUNT ON

	INSERT INTO MetricPermission (GroupSN, MetricCategorySN)
	SELECT (SELECT sn FROM MetricGroup WHERE GroupName = 'public'), sn
	FROM MetricCategory 

	INSERT INTO MetricPermission (GroupSN, ResNowSectionSN)
	SELECT (SELECT sn FROM MetricGroup WHERE GroupName = 'public'), sn
	FROM ResNowMenuSection
GO
GRANT EXECUTE ON  [dbo].[MetricPublicToAllPages] TO [public]
GO
