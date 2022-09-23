SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create function [dbo].[GetTrailerAlarms](@tch_id int, @ignoreresolved int) returns Varchar(MAX) as
begin
		declare @retval varchar(MAX), @WorkID int
		select @Retval = ''
		select @WorkID = MIN(tad_id) from traileralarmdetail where tch_id = @tch_id and (@ignoreresolved = 0 or tadr_id is null)
		while not (@WorkID is null)
		begin
			if datalength(@Retval)>0 select @Retval = @Retval + ','
			select @Retval = @Retval + isnull(tad_text, '') from traileralarmdetail where tad_id = @WorkID
			select @WorkID = MIN(tad_id) from traileralarmdetail where tch_id = @tch_id and tad_id > @WorkID
		end
		if @Retval = '' SELECT @Retval = 'NONE'
		return @Retval
end
GO
GRANT EXECUTE ON  [dbo].[GetTrailerAlarms] TO [public]
GO
