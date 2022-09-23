SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[d_loadrecid_with_inactive_sp] @rec varchar(40) , @number int 
AS

set nocount ON

DECLARE @daysout int, @date datetime
SELECT @daysout = -90
--vjh 31536
if exists ( SELECT lbp_id FROM ListBoxProperty where lbp_id=@@spid)
select @daysout = lbp_daysout, 
	@date = lbp_date
	from ListBoxProperty
	where lbp_id=@@spid
else
SELECT @daysout = gi_integer1, 
		 @date = gi_date1 FROM generalinfo WHERE gi_name = 'GRACE'
If @daysout <> 999 
	SELECT @date = dateadd (day, @daysout, getdate())

if @number = 1 
	set rowcount 1 
else if @number <= 8 
	set rowcount 8
else if @number <= 16
	set rowcount 16
else if @number <= 24
	set rowcount 24
else
	set rowcount 8

if exists ( SELECT 1 FROM recruitheader 
	WHERE rec_displayname LIKE @rec + '%') 
	
		Select rec_displayname
		FROM recruitheader 
		WHERE rec_displayname LIKE @rec + '%'
		ORDER BY rec_id 
Else
	select 'Unknown' as rec_displayname

set rowcount 0 

set nocount off

GO
GRANT EXECUTE ON  [dbo].[d_loadrecid_with_inactive_sp] TO [public]
GO
