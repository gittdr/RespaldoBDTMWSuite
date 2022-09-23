SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fnc_TMWRN_TrailerCommodityList]
	(@trl_number varchar(8),
	 @trl_ilt_scac varchar(4)='',
	 @mov_number int=0,
	 @end_date datetime ='20491231'
)
RETURNS VARCHAR(1024)
AS
BEGIN
declare @TrailerCommodityList varchar(1024)
declare @trl_id varchar(13)

If @trl_ilt_scac = ''
	SET @trl_id = @trl_number
ELSE
	SET @trl_id = @trl_ilt_scac + ',' + @trl_number 

IF @mov_number = 0
	BEGIN
	SET @mov_number = IsNull(
	(
	SELECT event.evt_mov_number 
	FROM    event (NOLOCK)
	Where  event.evt_number = 
	   (select max(aa.last_dne_evt_number)
	     from AssetAssignment aa (NOLOCK) 
	     where aa.asgn_id = @trl_id 
		   and aa.asgn_type = 'TRL' 
		   and aa.asgn_status IN ('CMP','STD'))
	), 0)
	END

declare @stp_loadstatus char(3)
SET @stp_loadstatus = 'UNK'
IF @end_date = '20491231'
	SET @stp_loadstatus = IsNull(
		(
		SELECT  stp_loadstatus
		FROM    event (NOLOCK), Stops (NOLOCK)
		Where   event.stp_number = stops.stp_number		       
	     and event.evt_number = 
		   (select max(aa.last_dne_evt_number)
		     from AssetAssignment aa (NOLOCK) 
		     where aa.asgn_id = @trl_id 
			   and aa.asgn_type = 'TRL' 
			   and aa.asgn_status IN ('CMP','STD'))
		), 'UNK')
	
IF @stp_loadstatus = 'MT'
	SET @TrailerCommodityList = (SELECT IsNull(trl_last_cmd,'') from trailerprofile (nolock) where trl_number = @trl_number and (trl_ilt_scac = @trl_ilt_scac or @trl_ilt_scac = ''))
ELSE
BEGIN
	SET @TrailerCommodityList = ''
	SELECT @TrailerCommodityList = @TrailerCommodityList + cmd_code + ','
	FROM	event (nolock), freightdetail (nolock)
	WHERE	( event.stp_number = freightdetail.stp_number ) AND  
		( event.evt_trailer1 = @trl_id ) AND
		( event.evt_mov_number = @mov_number OR @mov_number = 0 ) AND
		( event.evt_enddate < @end_date )
		and IsNull(cmd_code,'UNKNOWN') <> 'UNKNOWN'
	group by cmd_code
	
	IF @TrailerCommodityList > '' 
		SET @TrailerCommodityList = Left(@TrailerCommodityList,len(@TrailerCommodityList) -1)
END

return @TrailerCommodityList 
	
END
GO
