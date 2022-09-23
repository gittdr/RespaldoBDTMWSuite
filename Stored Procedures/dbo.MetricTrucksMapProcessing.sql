SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Proc [dbo].[MetricTrucksMapProcessing]
/* WITH ENCRYPTION */ -- Do not touch this line.  This gets uncommented in the build process if the file is to be encrypted.
AS
	SET NOCOUNT ON

Declare	@Lastsn int
Declare	@NextSn int
Declare	@MetricCode varchar(200)

	Select top 1 @NextSn = sn, @MetricCode=MetricCode
	From MetricItem
	Where ProcedureName = 'MapQ_CurrentGPSProM'
	order by sn
	SET @Lastsn = @NextSn 
WHILE @NextSn is not null
Begin
  	Exec MetricRun 	@MetricCode, @ShowDetail = -1 

	set @NextSn = null
	Select top 1 @NextSn = sn, @MetricCode=MetricCode
	From MetricItem
	Where ProcedureName = 'MapQ_CurrentGPSProM' 
	and sn > @Lastsn 
	order by sn
	SET @Lastsn = @NextSn 
End

GO
GRANT EXECUTE ON  [dbo].[MetricTrucksMapProcessing] TO [public]
GO
