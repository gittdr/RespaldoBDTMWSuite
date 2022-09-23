SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricUpdateItemProcessAttributes] 
(
	@MetricCode varchar(200),
	@ActiveProcess int,
	@ProcessSortOrder int,
	@RefreshHistoryYN varchar(1),
	@BriefingEmailAddressList varchar(255),
	@ScheduleMetric varchar(1),						-- Should be obsolete.
	@TimeValue int,									-- Should be obsolete.
	@TimeType varchar(25),							-- Should be obsolete.
	@DoNotIncludeTotalForNonBusinessDayYN varchar(1)
)
AS
	SET NOCOUNT ON

	UPDATE MetricItem SET
		Active = @ActiveProcess,
		Sort = @ProcessSortOrder,
		RefreshHistoryYN = @RefreshHistoryYN,
		BriefingEmailAddress = @BriefingEmailAddressList,
		ScheduleMetric = @ScheduleMetric,
		TimeValue = @TimeValue,
		TimeType = @TimeType,
		DoNotIncludeTotalForNonBusinessDayYN = @DoNotIncludeTotalForNonBusinessDayYN
	WHERE MetricCode = @MetricCode
GO
GRANT EXECUTE ON  [dbo].[MetricUpdateItemProcessAttributes] TO [public]
GO
