SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[outbound_view_brokerplan_stdpickedup](
	@lgh_startdate 		datetime,
	@lgh_enddate		datetime,
	@ord_bookedrevtype1list	varchar(8000), -- Typically a customer service rep in a broker outfit
	@lgh_bookedrevtype1list	varchar(8000), -- Typically a carrier rep in a broker outfit, usually matches ORD type 1 unless "re-assigned"
	@lgh_oustatuslist	varchar(255),
	@retrievemode		varchar(8),
	@billto			VARCHAR(8) = null,
	@revtype2		VARCHAR(6) = null)

AS
BEGIN
/*
2011.06.15 MTC PTS 57371 Added NoCount On. Added nolocks to selects to help w/Deadlocking at 1 customer.
-- SGB 51911 add Leg User Defined Fields
-- MTC 66176 major overhaul to dynamic SQL for performance reasons. Added an index also.
*/

set nocount on

declare @newcarrier as varchar (8),
	@pwextrainfolocation  VARCHAR(20),
	@v_LocalCityTZAdjMinutes	int,	
	@InDSTFactor				int,
	@DSTCountryCode				int ,
	@V_LocalGMTDelta			smallint,
	@v_LocalDSTCode				smallint,
	@V_LocalAddnlMins			smallint,
	@ud_columns smallint,
	@ud_column1 smallint, --PTS 51911 SGB
	@ud_column2 smallint,  --PTS 51911 SGB
	@ud_column3 smallint, --PTS 51911 SGB
	@ud_column4 smallint,  --PTS 51911 SGB
	@procname varchar(255), --PTS 51911 SGB
	@udheader varchar(30) --PTS 51911 SGB  

SELECT @newcarrier = Left (gi_string1, 8) from generalinfo where gi_name = 'PlanningCarrierID'
SELECT @newcarrier = Upper (IsNull (@newcarrier, 'NEWCAR' ))

SELECT @pwextrainfolocation = UPPER(ISNULL(gi_string1, 'orderheader'))
  FROM generalinfo
 WHERE gi_name = 'PWExtraInfoLocation'

If @lgh_bookedrevtype1list = '' 
Select @lgh_bookedrevtype1list = 'ALL'

If @ord_bookedrevtype1list = ''
Select @ord_bookedrevtype1list = 'ALL'

SELECT @ord_bookedrevtype1list = ',' + LTRIM(RTRIM(ISNULL(@ord_bookedrevtype1list, ''))) + ',' 
SELECT @lgh_bookedrevtype1list = ',' + LTRIM(RTRIM(ISNULL(@lgh_bookedrevtype1list, ''))) + ','
SELECT @lgh_oustatuslist = ',' + LTRIM(RTRIM(ISNULL(@lgh_oustatuslist, ''))) + ','

/* PTS61940 MBR 06/13/12 */
IF @billto IS NULL OR @billto = ''
BEGIN
   SET @billto = 'UNKNOWN'
END
IF @revtype2 IS NULL OR @revtype2 = ''
BEGIN
   SET @revtype2 = 'UNK'
END   

/* 04/23/2012 MDH PTS 60772: <<BEGIN>> */
select @DSTCountryCode = 0 /* if you want to work outside North America, set this value see proc ChangeTZ */
select @InDSTFactor = case dbo.InDst(getdate(),@DSTCountryCode) when 'Y' then 1 else 0 end
exec getusertimezoneinfo @V_LocalGMTDelta output,@v_LocalDSTCode output,@V_LocalAddnlMins  output
select @v_LocalCityTZAdjMinutes =
   ((@V_LocalGMTDelta + (@InDSTFactor * @v_LocalDSTCode)) * 60) +   @V_LocalAddnlMins
/* 04/23/2012 MDH PTS 60772: <<END>> */

declare @SQL nvarchar(MAX)
select @SQL = N'Select lgh_number,lgh_booked_revtype1,o.ord_booked_revtype1,''BookingTerminal'' as brn_bookingterminal_t,''ExecutingTerminal'' as brn_executingterminal_t, '
select @SQL = @SQL + N'lgh_outstatus,lgh_startdate,lgh_enddate,ord_origin_earliestdate,ord_origin_latestdate,ord_dest_earliestdate,ord_dest_latestdate,c1.cty_name ''ord_origin_city'', '
select @SQL = @SQL + N'c1.cty_state ''ord_origin_state'', c2.cty_name ''ord_dest_city'', c2.cty_state ''ord_dest_state'',c3.cty_name ''lgh_origin_city'',c3.cty_state ''lgh_origin_state'', '
select @SQL = @SQL + N'c4.cty_name ''lgh_dest_city'', c4.cty_state ''lgh_dest_state'', o.ord_revtype1,o.ord_revtype2,o.ord_revtype3,o.ord_revtype4,''RevType1'' as revtype1_t, '
select @SQL = @SQL + N'''RevType2'' as revtype2_t,''RevType3'' as revtype3_t,''RevType4'' as revtype4_t,l.lgh_type1,l.lgh_type2,''LghType1'' as lghtype1_t,''LghType2'' as lghtype2_t, '
select @SQL = @SQL + N'l.mov_number, o.ord_hdrnumber,o.ord_number,l.lgh_schdtearliest,l.lgh_schdtlatest, l.lgh_carrier, '
			If @pwextrainfolocation = 'ORDERHEADER'
	begin
		select @SQL = @SQL + N'ord_extrainfo1 as extrainfo1,ord_extrainfo2 as extrainfo2,ord_extrainfo3 as extrainfo3,ord_extrainfo4 as extrainfo4, '
		select @SQL = @SQL + N'ord_extrainfo5 as extrainfo5,ord_extrainfo6 as extrainfo6,ord_extrainfo7 as extrainfo7,ord_extrainfo8 as extrainfo8, '
		select @SQL = @SQL + N'ord_extrainfo9 as extrainfo9,ord_extrainfo10 as extrainfo10,ord_extrainfo11 as extrainfo11,ord_extrainfo12 as extrainfo12, '
		select @SQL = @SQL + N'ord_extrainfo13 as extrainfo13,ord_extrainfo14 as extrainfo14,ord_extrainfo15 as extrainfo15, '
	end
else
	begin
		select @SQL = @SQL + N'lgh_extrainfo1 as extrainfo1,lgh_extrainfo2 as extrainfo2,lgh_extrainfo3 as extrainfo3,lgh_extrainfo4 as extrainfo4, '
		select @SQL = @SQL + N'lgh_extrainfo5 as extrainfo5,lgh_extrainfo6 as extrainfo6,lgh_extrainfo7 as extrainfo7,lgh_extrainfo8 as extrainfo8, '
		select @SQL = @SQL + N'lgh_extrainfo9 as extrainfo9,lgh_extrainfo10 as extrainfo10,lgh_extrainfo11 as extrainfo11,lgh_extrainfo12 as extrainfo12, '
		select @SQL = @SQL + N'lgh_extrainfo13 as extrainfo13,lgh_extrainfo14 as extrainfo14,lgh_extrainfo15 as extrainfo15, '
	end

select @SQL = @SQL + convert(nvarchar(10),@v_LocalCityTZAdjMinutes) + '- ((isnull(c1.cty_GMTDelta,5) + (' + convert(nvarchar(10),@InDSTFactor) + ' '
select @SQL = @SQL + N'* (case c1.cty_DSTApplies when ''Y'' then 0 else 1 end))) * 60) + isnull(c1.cty_TZMins,0) as NeedsName1, '
select @SQL = @SQL + convert(nvarchar(10),@v_LocalCityTZAdjMinutes) + '- ((isnull(c1.cty_GMTDelta,5) + (' + convert(nvarchar(10),@InDSTFactor) + ' '
select @SQL = @SQL + N'* (case c2.cty_DSTApplies when ''Y'' then 0 else 1 end))) * 60) + isnull(c2.cty_TZMins,0) as NeedsName2, '

--PTS 51911 SGB Only run when setting turned on 
Select @ud_columns = count(*) from generalinfo where gi_name = 'UD_STOP_LEG_COLUMNS'
If @ud_columns > 0
BEGIN
	select @ud_column1 = count(*) from generalinfo where gi_name = 'UD_STOP_LEG_COLUMNS' and gi_string1 = 'Y'
	Select @ud_column2 = count(*) from generalinfo where gi_name = 'UD_STOP_LEG_COLUMNS' and gi_string2 = 'Y'
	Select @ud_column3 = count(*) from generalinfo where gi_name = 'UD_STOP_LEG_COLUMNS' and gi_string3 = 'Y'
	Select @ud_column4 = count(*) from generalinfo where gi_name = 'UD_STOP_LEG_COLUMNS' and gi_string4 = 'Y'

	if @ud_column1 > 0
	BEGIN
		select @SQL = @SQL + N'dbo.UD_STOP_LEG_SHELL_FN (l.lgh_number,''LS'',1) as ud_column1, '
		select @SQL = @SQL + N'dbo.UD_STOP_LEG_SHELL_FN (l.lgh_number,''H'',1) as ud_column1_t, '
	END

	if @ud_column2 > 0
	BEGIN
		select @SQL = @SQL + N'dbo.UD_STOP_LEG_SHELL_FN (l.lgh_number,''LE'',2) as ud_column2, '
		select @SQL = @SQL + N'dbo.UD_STOP_LEG_SHELL_FN (l.lgh_number,''H'',2) as ud_column2_t, '
	END

	if @ud_column3 > 0
	BEGIN
		select @SQL = @SQL + N'dbo.UD_STOP_LEG_SHELL_FN (l.lgh_number,''L'',3) as ud_column3, '
		select @SQL = @SQL + N'dbo.UD_STOP_LEG_SHELL_FN (l.lgh_number,''H'',3) as ud_column3_t, '
	END

	if @ud_column4 > 0
	BEGIN
		select @SQL = @SQL + N'dbo.UD_STOP_LEG_SHELL_FN (l.lgh_number,''L'',4) as ud_column4, '
		select @SQL = @SQL + N'dbo.UD_STOP_LEG_SHELL_FN (l.lgh_number,''H'',4) as ud_column4_t, '
	END
END
ELSE
	BEGIN
		select @SQL = @SQL + N'''UNKNOWN'' as ud_column1, '
		select @SQL = @SQL + N'''UD Column1'' as ud_column1_t, '
		select @SQL = @SQL + N'''UNKNOWN'' as ud_column2, '
		select @SQL = @SQL + N'''UD Column2'' as ud_column2_t, '
		select @SQL = @SQL + N'''UNKNOWN'' as ud_column3, '
		select @SQL = @SQL + N'''UD Column3'' as ud_column3_t, '
		select @SQL = @SQL + N'''UNKNOWN'' as ud_column3, '
		select @SQL = @SQL + N'''UD Column4'' as ud_column4_t, '
	END
/*END PTS 51911 SGB custom columns*/

--remove 2 spaces - (last comma and space afterward)
select @SQL = substring(@SQL,1,len(@SQL) - 1)								

select @SQL = @SQL + N' from legheader_active l With (NoLock) inner join orderheader o With (NoLock) on l.mov_number = o.mov_number '  

select @SQL = @SQL + N'inner join city c1 With (NoLock) on o.ord_origincity = c1.cty_code '   
select @SQL = @SQL + N'inner join city c2 With (NoLock) on o.ord_destcity = c2.cty_code  '  
select @SQL = @SQL + N'inner join city c3 With (NoLock) on l.lgh_startcity = c3.cty_code  '  
select @SQL = @SQL + N'inner join city c4 With (NoLock) on l.lgh_endcity = c4.cty_code  '
select @SQL = @SQL + N'where o.ord_origin_earliestdate between ''' +  convert(varchar(20),@lgh_startdate) + ''' and ''' + convert(varchar(20),@lgh_enddate) + ''' '

if @billto <> 'UNKNOWN'
select @SQL = @SQL + N'and o.ord_billto = ''' + @billto + ''' '

if @revtype2 <> 'UNK'
select @SQL = @SQL + N'and o.ord_revtype2 = ''' + @revtype2 + ''' '

select @SQL = @SQL + N'and lgh_outstatus = ''STD'' AND ord_status = ''STD'' AND l.lgh_carrier <> ''' + @newcarrier + ''' '
			
if left(@ord_bookedrevtype1list,5) <> ',ALL,'
begin
	select @ord_bookedrevtype1list = substring(@ord_bookedrevtype1list, 2,len(@ord_bookedrevtype1list)-2)
	select @ord_bookedrevtype1list = replace(@ord_bookedrevtype1list,',',''',''' )

	if @retrievemode = 'SINGLE'
		select @ord_bookedrevtype1list = @ord_bookedrevtype1list + ''',''UNK'',''UNKNOWN'

	select @SQL = @SQL + N' and ord_booked_revtype1 in (''' + @ord_bookedrevtype1list + ''')'

end

if left(@lgh_bookedrevtype1list,5) <> ',ALL,'
begin
	select @lgh_bookedrevtype1list = substring(@lgh_bookedrevtype1list, 2,len(@lgh_bookedrevtype1list)-2)
	select @lgh_bookedrevtype1list = replace(@lgh_bookedrevtype1list,',',''',''' )

	if @retrievemode = 'SINGLE'
		select @lgh_bookedrevtype1list = @lgh_bookedrevtype1list + ''',''UNK'',''UNKNOWN'

	select @SQL = @SQL + N' and lgh_booked_revtype1 in (''' + @lgh_bookedrevtype1list + ''')'

end			
				
exec sp_executesql @SQL  				
 
		

END

GO
GRANT EXECUTE ON  [dbo].[outbound_view_brokerplan_stdpickedup] TO [public]
GO
