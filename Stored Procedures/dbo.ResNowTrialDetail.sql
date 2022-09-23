SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[ResNowTrialDetail] 
(
	@Mode varchar(64), 
	@NumberOfValues int, -- when = 0 flags for ShowDetail
	@ItemID varchar(255),  -- when = '' flags for showing Detail of "other" (last piece of pie)
	@DateStart datetime = NULL, 
	@DateEnd datetime = NULL,
	@Parameters varchar(255)= '',
	@ReturnDetail_YN varchar(1) = 'Y'
)
AS 

	SET NOCOUNT ON

	DECLARE @LastUpdate datetime
	DECLARE @MaximumCacheAgeInHours int
	DECLARE @Refresh int
	DECLARE @SQL	VARCHAR(4000)
	DECLARE @ProcedureName VARCHAR(50)

	SET @Refresh = 0

	SET @MaximumCacheAgeInHours = round(20 + .4 * convert(int, right(convert(varchar(20), RAND(Datepart(ms, GETDATE()))),1)),0)

	-- If either @DateStart or @DateEnd IS NULL, then set it to tomorrow.
	IF (@DateStart IS NULL OR @DateEnd IS NULL )
	BEGIN
		SELECT @DateEnd = ISNULL(@DateEnd, CONVERT(varchar(10), DATEADD(day, 1, GETDATE()), 121)) 
		SELECT @DateStart = DATEADD(d, -30, @DateEnd)
	END
	-- Cache these in MetricProcessingTrial stored procedure

	SET @LastUpdate = (SELECT TOP 1 LastUpdate FROM RNTrial_Cache_TopValues (NOLOCK) WHERE ItemCategory = @Mode)

	IF DATEDIFF(hour, ISNULL(@LastUpdate, '19500101'), GETDATE()) > @MaximumCacheAgeInHours
		SET @Refresh = 1

	IF @Refresh = 1
		DELETE FROM RNTrial_Cache_TopValues WHERE ItemCategory = @Mode

	IF IsNull(@NumberOfValues,0) = 0 OR @Refresh = 1
		BEGIN
	    SET @ProcedureName = (SELECT Top 1 ProcedureName FROM RN_OverviewParameter WHERE Mode = @Mode)
		If Exists (Select * from sysobjects (NOLOCK) where name = @ProcedureName and type='P')
			BEGIN
			SET @SQL = 'EXEC ' + @ProcedureName + ' ' + convert(varchar(5), @NumberOfValues)  + ', ''' + @ItemID + ''', ''' + convert(varchar(16), @DateStart, 20) + ''', ''' +  convert(varchar(16), @DateEnd, 20) + ''', ''' +  @Parameters + ''', ' +  convert(varchar(2), @Refresh)  + ', @Mode=''' + @Mode + ''''
			EXEC (@SQL) 
			END
		END

	IF IsNull(@NumberOfValues,0) > 0 AND ISNULL(@ReturnDetail_YN, 'Y') = 'Y'
	BEGIN
		SELECT [LastUpdate],[DateStart],[DateEnd],[ItemCategory],[ItemID],[ItemDescription],[Count],[Percentage] 
		 FROM RNTrial_Cache_TopValues (NOLOCK) WHERE ItemCategory = @Mode
		ORDER By RecNum
	END

GO
GRANT EXECUTE ON  [dbo].[ResNowTrialDetail] TO [public]
GO
