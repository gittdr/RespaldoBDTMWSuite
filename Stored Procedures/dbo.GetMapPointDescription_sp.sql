SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[GetMapPointDescription_sp](@ckc_number int,	@rc	varchar(max) OUTPUT)

AS

/**
 * 
 * NAME:
 * dbo.GetMapPointDescription_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 *  Create the description used for the trailer checkcall on the trailer profile tracking map.
 *
 * RETURNS:
 *  none
 *
 * RESULT SETS: 
 *  none
 *
 * PARAMETERS:
 * 001 - @ckc_number int
 * 002 - @rc varchar(max) OUTPUT
 *
 * REFERENCES:
 * none
 * 
 * REVISION HISTORY:
 * 10/12/2011.01 - PTS54134 - MIZ - Added time to date field and fixed formatting.
 *
 **/

BEGIN
	DECLARE	@ckc_date		datetime,
			@asgn_type		varchar(6),
			@asgn_id		varchar(13),
			@lat			float,
			@long			float,
			@ord_number		varchar(12),
			@ord_origin		varchar(8),
			@ord_dest		varchar(8),
			@ord_desc		varchar(60),
			@cmd_code		varchar(8),
			@alarm_summary	varchar(6)

	SET NOCOUNT ON
		
	select distinct @ckc_date = checkcall.ckc_date, 
					@asgn_type = checkcall.ckc_asgntype,
					@asgn_id = checkcall.ckc_asgnid,
					@lat = checkcall.ckc_latseconds, 
					@long = checkcall.ckc_longseconds,
					@ord_number = orderheader.ord_number, 
					@ord_origin = orderheader.ord_originpoint, 
					@ord_dest =  orderheader.ord_destpoint,
					@ord_desc = orderheader.ord_description,
					@cmd_code = orderheader.cmd_code, 
					@alarm_summary = trailercommhistory.tch_alarmsummary
	from checkcall
			left outer join orderheader on ord_hdrnumber = dbo.GetOrdHdrForAssetAndDate(checkcall.ckc_asgntype, checkcall.ckc_asgnid, checkcall.ckc_date) 
			left outer join trailercommhistory on checkcall.ckc_number = trailercommhistory.ckc_number
	WHERE checkcall.ckc_number = @ckc_number order by ckc_date

	set @rc = 'Check Call Date: ' + CONVERT(varchar(20),isnull(@ckc_date, ''), 120) + CHAR(13) + CHAR(10) 
	set @rc = @rc + 'Lat\Long: (' + RTRIM(convert(varchar(7),(isnull(@lat, 0) / 3600))) + ', ' + RTRIM(convert(varchar(7),(isnull(@long, 0) / 3600))) + ')' + CHAR(13) + CHAR(10) 
	set @rc = @rc + 'Asset ID: ' + RTRIM(isnull(@asgn_id, '')) + CHAR(13) + CHAR(10)
	set @rc = @rc + 'Order Number: ' + RTRIM(isnull(@ord_number, '')) + CHAR(13) + CHAR(10)
	set @rc = @rc + 'Order Description: ' + RTRIM(isnull(@ord_desc, '')) +  CHAR(13) + CHAR(10)  
	SET @rc = @rc + 'Commodity Code: ' + RTRIM(isnull(@cmd_code, '')) + CHAR(13) + CHAR(10)
	set @rc = @rc + 'Alarm Summary: ' + isnull(@alarm_summary, '')
		
END

GO
GRANT EXECUTE ON  [dbo].[GetMapPointDescription_sp] TO [public]
GO
