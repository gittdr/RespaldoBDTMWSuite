SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROC [dbo].[rpt_crst_tariff_actv_detail] (
  @s_date datetime,
  @e_date datetime,
  @ASSIGNED_USER varchar(20),
  @displaysub int)

AS

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

declare @cur_date datetime
set @cur_date = GETDATE()

SET @e_date = convert(datetime, convert(varchar(11), @e_date, 101) + ' 23:59:59')
  
SELECT 
  th.tar_number as [Tariff],
  th.tar_tarriffnumber as [QuoteID],
  th.tar_description as [Description],
  tk.trk_billto as [CompanyID],
  (select cmp_name from company where cmp_id = tk.trk_billto) as [CompanyName],
  th.cht_itemcode as [ChargeType],
  th.tar_rate as [Rate],
  CASE WHEN @cur_date between tk.trk_startdate and tk.trk_enddate  THEN 'Active' ELSE 'InActive' END AS [Status],
  tk.trk_startdate as [Effect Date],
  tk.trk_enddate as [Expire Date],  
  th.tar_creatdate as [Created Date],
  th.tar_updateon as [Last Updated],
  th.tar_updateby as [Last Updated By],
  case when tk.trk_originpoint = 'UNKNOWN' then '' else tk.trk_originpoint end as [Origin CMP],
  (select cty_name from city where cty_code = tk.trk_origincity) as [Origin City],
  case when trk_originzip = 'UNKNOWN' then '' else trk_originzip end as [Origin Zip],
  case when trk_originstate = 'UNKNOWN' then '' else trk_originstate end as [Origin State],
  case when tk.trk_destpoint = 'UNKNOWN' then '' else tk.trk_destpoint end as [Dest CMP],
  (select cty_name from city where cty_code = tk.trk_destcity) as [Dest City],
  case when trk_destzip = 'UNKNOWN' then '' else trk_destzip end as [Dest Zip],
  case when trk_deststate = 'UNKNOWN' then '' else trk_deststate end as [Dest State]
FROM tariffheader th
  INNER JOIN tariffkey tk ON th.tar_number = tk.tar_number   
WHERE tar_updateon BETWEEN @s_date AND @e_date  
AND th.tar_updateby = @ASSIGNED_USER
AND @displaysub = 1


GO
GRANT EXECUTE ON  [dbo].[rpt_crst_tariff_actv_detail] TO [public]
GO
