SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricOverviewProcessing] (@PassedMode AS varchar(50) = '', @ReturnDetail_YN varchar(1) = 'Y' )
AS
	SET NOCOUNT ON

	DECLARE @Mode varchar(500),
			@NumberOfValues Int,
			@DaysRange int,
 			@DaysBack int,
 			@DateStart datetime,
 			@DateEnd datetime,
			@Parameters varchar(500) ,
			@Lastsn int,
			@NextSn int

	IF @PassedMode = ''
	BEGIN
		SELECT TOP 1 @NextSn = sn, @Mode=Mode, @NumberOfValues=NumberOfValues, @DaysRange=DaysRange, @DaysBack=DaysBack, @Parameters=Parameters
		FROM RN_OverviewParameter
		WHERE Active = 1 
		ORDER BY sn

		SET @Lastsn = @NextSn 

		WHILE @NextSn is not null
		Begin
			SET @DateEnd = DateAdd(d,-@DaysBack,GetDate())
			SET @DateStart = DateAdd(d, -@DaysRange, @DateEnd)
			Exec ResNowTrialDetail 
				@Mode, 
				@NumberOfValues, 
				'', 
				@DateStart,
				@DateEnd,
				@Parameters,
				@ReturnDetail_YN

			set @NextSn = null
			Select top 1 @NextSn = sn, @Mode=Mode, @NumberOfValues=NumberOfValues, @DaysRange=DaysRange, @DaysBack=DaysBack, @Parameters=Parameters
			From RN_OverviewParameter (NOLOCK)
			Where Active = 1 and sn > @Lastsn 
			order by sn
			SET @Lastsn = @NextSn 
		END
	END
	ELSE
	BEGIN
		SELECT @NextSn = sn, @Mode=Mode, @NumberOfValues=NumberOfValues, @DaysRange=DaysRange, @DaysBack=DaysBack, @Parameters=Parameters
		FROM RN_OverviewParameter
		WHERE Mode = @PassedMode 
			AND Active = 1

		IF @Mode > ''
		BEGIN
			SET @DateEnd = DateAdd(d,-@DaysBack,GetDate())
			SET @DateStart = DateAdd(d, -@DaysRange, @DateEnd)
  			Exec ResNowTrialDetail
				@Mode, 
				@NumberOfValues, 
				'', 
				@DateStart,
				@DateEnd,
				@Parameters,
				@ReturnDetail_YN
		END
		ELSE
			SELECT '''' + @PassedMode + ''' is not active or not a valid mode'
	END

GO
GRANT EXECUTE ON  [dbo].[MetricOverviewProcessing] TO [public]
GO
