SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROC [dbo].[rpt_crst_user_quote_total_by_status] (
  @ASSIGNED_USER varchar(20),
  @s_date datetime,
  @e_date datetime)

AS

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

declare @cur_date datetime
set @cur_date = GETDATE()

SET @e_date = convert(datetime, convert(varchar(11), @e_date, 101) + ' 23:59:59')


SELECT 
  th.tar_updateby,
  CASE WHEN @cur_date between tk.trk_startdate and tk.trk_enddate  THEN 'Active' ELSE 'InActive' END AS [Status],
  COUNT(*) AS [ACTIVITY COUNT]
FROM tariffheader th
  INNER JOIN tariffkey tk ON th.tar_number = tk.tar_number 
WHERE tar_updateon BETWEEN @s_date AND @e_date  
AND th.tar_updateby = @ASSIGNED_USER
GROUP BY th.tar_updateby, CASE WHEN @cur_date between tk.trk_startdate and tk.trk_enddate  THEN 'Active' ELSE 'InActive' END


GO
GRANT EXECUTE ON  [dbo].[rpt_crst_user_quote_total_by_status] TO [public]
GO
