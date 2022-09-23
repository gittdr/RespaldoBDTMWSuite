SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_createstop214pending]
						@lStopNum int, 
						@activitycode varchar(6),
						@activitydate datetime
AS

SET NOCOUNT ON 

	DECLARE 
		@firstlastflags	varchar(20),
		@firststopoftype	int,
		@laststopoftype	int,
		@ord_hdrnumber	int,
		@stp_type	varchar(6),
		@stp_sequence int
		
	DECLARE @slacktime datetime
		SELECT  @slacktime = convert(smallint,ISNULL(gi_string1,'0'))
		FROM    generalinfo (NOLOCK)
		WHERE   gi_name = 'SlackTime'
	
	SELECT @slacktime = ISNULL(@slacktime,0)
	
	SELECT @activitydate = ISNULL(@activitydate, GETDATE())
	
	SELECT @ord_hdrnumber = ord_hdrnumber,
		@stp_type = stp_type,
		@stp_sequence = stp_sequence
	FROM stops (NOLOCK) 
	WHERE stp_number = @lStopNum
	
	SELECT @ord_hdrnumber = ISNULL(@ord_hdrnumber,0),
		@stp_type = ISNULL(@stp_type,'')
	
	SELECT @firststopoftype = MIN(stp_sequence),
		@laststopoftype = MAX(stp_sequence)
	FROM stops (NOLOCK)
	WHERE ord_hdrnumber = @ord_hdrnumber and
			stp_type = @stp_type
			
		SELECT @firstlastflags = '0'
		SELECT @firstlastflags =
			CASE 
				WHEN @stp_sequence = @firststopoftype
					THEN @firstlastflags + ',1'
				WHEN @stp_sequence > @firststopoftype
					THEN @firstlastflags + ',2'
				ELSE 
					@firstlastflags
				END
		SELECT @firstlastflags = 
			CASE 
				WHEN @stp_sequence < @laststopoftype
					THEN @firstlastflags + ',3'
				WHEN @stp_sequence = @laststopoftype
					THEN @firstlastflags + ',99'
				ELSE
					@firstlastflags
				END

	INSERT edi_214_pending (
		e214p_ord_hdrnumber,		-- 1
		e214p_billto,			-- 2
		e214p_level,			-- 3
		e214p_ps_status,		-- 4
		e214p_stp_number,		-- 5
		e214p_dttm,			-- 6
		e214p_activity,			-- 7
		e214p_arrive_earlyorlate,	-- 8
		e214p_depart_earlyorlate,	-- 9
		e214p_stpsequence,		--10
		ckc_number,			--11
		e214p_firstlastflags,		--12
		e214p_created,			--13
	    e214p_ReplicateForEachDropFlag)	--14
	SELECT 
		stops.ord_hdrnumber,			-- 1
		ord_billto,			-- 2
		Case stp_type			-- 3
			When 'PUP' Then 'SH'
			When 'DRP' Then 'CN'
			Else 'NON'
			End,
		'',			-- 4
		@lStopNum,			-- 5
		@activitydate,			-- 6
		@activitycode,			-- 7
		Case			-- 8
			When stops.stp_schdtlatest < '20491231' and
            	DATEDIFF(mi,stops.stp_schdtlatest, stops.stp_arrivaldate) > @slacktime
                Then 'L'
			When stops.stp_schdtearliest > '19500101' and
            	stops.stp_arrivaldate < stops.stp_schdtearliest
                Then 'E'
            Else ' '
        	End,
		' ',			-- 9
		stp_sequence,			--10
		0,	--11
		@firstlastflags,			--12
		getdate(),			--13
	    'N' 			--14
	FROM stops (NOLOCK)
	LEFT OUTER JOIN orderheader (NOLOCK) ON stops.ord_hdrnumber = orderheader.ord_hdrnumber
	WHERE stp_number = @lStopNum AND ISNULL(stops.ord_hdrnumber,0) <> 0 -- Currently edi only is expected for order stops.
GO
GRANT EXECUTE ON  [dbo].[tmail_createstop214pending] TO [public]
GO
