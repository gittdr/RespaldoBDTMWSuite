SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create function [dbo].[GetTrailerAlarmsByTrailerID](@trl_id varchar(13)) returns Varchar(MAX) as
begin
		declare @retval varchar(MAX), @tch_id int		select @Retval = ''
		-- initalize variables
		select @Retval = ''
		select @tch_id = 0
		
		-- Get Last Trailer Comm History record that is not null for the trailer
		select top 1 @tch_id = tch_id from trailercommhistory where trl_id = @trl_id and isnull(tch_alarmsummary, '') <> '' order by tch_id desc
		
		if @tch_id > 0
			select @Retval = dbo.GetTrailerAlarms(@tch_id, 0) 
		
		return @Retval
end
GO
GRANT EXECUTE ON  [dbo].[GetTrailerAlarmsByTrailerID] TO [public]
GO
