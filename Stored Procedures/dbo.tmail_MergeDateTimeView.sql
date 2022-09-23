SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_MergeDateTimeView] (@datefield varchar(30), @timefield varchar(30), @RefDate varchar(30) = NULL) 

AS

SET NOCOUNT ON

	declare @result datetime
	if isdate(@refdate) = 0 SELECT @refdate = GETDATE()
	if (isnull(@datefield, '') = '' and isnull(@timefield, '') = '')
		BEGIN
		SELECT CONVERT(varchar(19), '') as result
		END
	else
		BEGIN
		exec dbo.tmail_MergeDateTime @datefield, @timefield, @result out, @refdate
		SELECT CONVERT(varchar(19), @result, 20) as result
		END
GO
GRANT EXECUTE ON  [dbo].[tmail_MergeDateTimeView] TO [public]
GO
