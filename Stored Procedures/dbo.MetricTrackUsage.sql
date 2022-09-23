SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricTrackUsage] 
(
	@UserID int = 0,
	@Category varchar(100) = '',
	@Layer varchar(100) = '',
	@Metric varchar(100)='',
	@DetailYN varchar(1)='N',
	@RequestType varchar(100) = 'Unknown'
)
/* WITH ENCRYPTION */ -- Do not touch this line.  This gets uncommented in the build process if the file is to be encrypted.
AS	
	SET NOCOUNT ON

	Insert Into ResNowTrackUsage (UserID, UsageDate, Category, Layer, Metric, DetailYN, RequestType)
	Values
	(@UserID, GetDate(),@Category, @Layer, @Metric, @DetailYN, @RequestType)						

GO
GRANT EXECUTE ON  [dbo].[MetricTrackUsage] TO [public]
GO
